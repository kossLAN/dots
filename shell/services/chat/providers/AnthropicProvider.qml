pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs
import qs.widgets
import qs.services.chat
import qs.launcher.settings

ChatProvider {
    id: root

    enabled: false
    name: "Anthropic"
    icon: "anthropic"
    providerId: "anthropic"
    apiEndpoint: "https://api.anthropic.com"

    property string apiKey: ""

    available: false
    // Anthropic Claude models support images (vision capability)
    supportsImages: _isVisionModel(currentModel)

    // Check if current model supports vision
    function _isVisionModel(modelName) {
        if (!modelName) return false;
        let lower = modelName.toLowerCase();
        // Claude 3+ models support vision (Haiku, Sonnet, Opus)
        // Claude 2.x and earlier do not support images
        return lower.includes("claude-3") ||
               lower.includes("claude-sonnet") ||
               lower.includes("claude-haiku") ||
               lower.includes("claude-opus");
    }

    // Helper to detect media type from base64 data
    function _detectMediaType(base64Data) {
        // Check for common image signatures in base64
        if (base64Data.startsWith("/9j/")) return "image/jpeg";
        if (base64Data.startsWith("iVBOR")) return "image/png";
        if (base64Data.startsWith("R0lGO")) return "image/gif";
        if (base64Data.startsWith("UklGR")) return "image/webp";
        // Default to JPEG if unknown
        return "image/jpeg";
    }

    settings: ColumnLayout {
        spacing: 4

        SettingsCard {
            title: "API Key"
            summary: "Your Anthropic API key"

            controls: StyledTextInput {
                text: root.apiKey
                width: 250
                placeholderText: "sk-ant-..."
                echoMode: TextInput.Password

                onAccepted: {
                    ChatConnector.setProviderApiKey(root.providerId, text);
                    root.apiKey = text;
                    root.checkAvailability();
                }
            }

            Layout.fillWidth: true
            Layout.preferredHeight: 36
        }
    }

    // Track current XMLHttpRequest for chat (to support cancellation)
    property var _chatRequest: null
    property int _lastProcessedIndex: 0

    function _processStreamingResponse(): void {
        if (!_chatRequest) return;

        let responseText = _chatRequest.responseText;
        if (responseText.length <= _lastProcessedIndex) return;

        // Get new data since last processed
        let newData = responseText.substring(_lastProcessedIndex);
        let lines = newData.split("\n");

        // Process complete lines (keep last incomplete line for next iteration)
        for (let i = 0; i < lines.length - 1; i++) {
            let line = lines[i].trim();
            if (line === "") continue;

            // SSE format: lines starting with "data: "
            if (line.startsWith("data: ")) {
                let jsonStr = line.substring(6);
                if (jsonStr === "[DONE]") continue;

                try {
                    let event = JSON.parse(jsonStr);

                    if (event.type === "content_block_delta" && event.delta?.text) {
                        let chunk = event.delta.text;
                        root.currentResponse += chunk;
                        root.responseChunk(chunk);
                    }

                    if (event.type === "message_stop") {
                        root.busy = false;
                        root.responseComplete(root.currentResponse);
                        root._chatRequest = null;
                        return;
                    }

                    if (event.type === "error") {
                        root.busy = false;
                        root.errorMessage = event.error?.message || "Unknown error";
                        root.responseError(root.errorMessage);
                        root._chatRequest = null;
                        return;
                    }
                } catch (e) {
                    // Ignore parse errors for partial data
                }
            }
        }

        // Update last processed index (keep incomplete last line)
        let lastNewlineIndex = newData.lastIndexOf("\n");
        if (lastNewlineIndex >= 0) {
            _lastProcessedIndex += lastNewlineIndex + 1;
        }
    }

    function fetchModels(): void {
        if (root.apiKey === "") {
            root.available = false;
            root.models = [];
            root.errorMessage = "API key required";
            return;
        }

        let xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        let response = JSON.parse(xhr.responseText);
                        let modelNames = [];

                        if (response.data && Array.isArray(response.data)) {
                            for (let model of response.data) {
                                if (model.id) {
                                    modelNames.push(model.id);
                                }
                            }
                        }

                        root.models = modelNames;
                        root.available = modelNames.length > 0;

                        if (modelNames.length > 0 && root.currentModel === "") {
                            root.currentModel = modelNames[0];
                        }

                        root.modelsLoaded(modelNames);
                        root.errorMessage = "";
                    } catch (e) {
                        console.error("Anthropic: Failed to parse models response:", e);
                        root.errorMessage = "Failed to parse models response";
                        root.available = false;
                    }
                } else if (xhr.status === 401) {
                    root.available = false;
                    root.models = [];
                    root.errorMessage = "Invalid API key";
                } else {
                    root.available = false;
                    root.models = [];
                    root.errorMessage = "Failed to connect to Anthropic";
                }
            }
        };

        xhr.open("GET", `${root.apiEndpoint}/v1/models?limit=100`);
        xhr.setRequestHeader("x-api-key", root.apiKey);
        xhr.setRequestHeader("anthropic-version", "2023-06-01");
        xhr.send();
    }

    // Build content array for Anthropic API (supports text and images)
    function _buildContentArray(text, images) {
        let content = [];

        // Add images first if present
        if (images && Array.isArray(images)) {
            for (let img of images) {
                content.push({
                    type: "image",
                    source: {
                        type: "base64",
                        media_type: _detectMediaType(img),
                        data: img
                    }
                });
            }
        }

        // Add text content
        content.push({
            type: "text",
            text: text
        });

        return content;
    }

    function sendMessage(message, history, images = null) {
        if (root.busy) {
            console.warn("Anthropic: Already processing a request");
            return;
        }

        if (root.currentModel === "") {
            root.errorMessage = "No model selected";
            root.responseError(root.errorMessage);
            return;
        }

        if (root.apiKey === "") {
            root.errorMessage = "API key required";
            root.responseError(root.errorMessage);
            return;
        }

        root.busy = true;
        root.currentResponse = "";
        root.errorMessage = "";
        root._lastProcessedIndex = 0;

        // Build messages array
        let messages = [];

        if (history && Array.isArray(history)) {
            for (let msg of history) {
                // Check if history message has images
                if (msg.images && Array.isArray(msg.images) && msg.images.length > 0) {
                    messages.push({
                        role: msg.role,
                        content: _buildContentArray(msg.content, msg.images)
                    });
                } else {
                    messages.push({
                        role: msg.role,
                        content: msg.content
                    });
                }
            }
        }

        // Build current message - use content array if images are present
        if (images && Array.isArray(images) && images.length > 0) {
            messages.push({
                role: "user",
                content: _buildContentArray(message, images)
            });
        } else {
            messages.push({
                role: "user",
                content: message
            });
        }

        let payload = {
            model: root.currentModel,
            max_tokens: 8192,
            messages: messages,
            stream: true
        };

        let xhr = new XMLHttpRequest();
        root._chatRequest = xhr;

        xhr.onreadystatechange = function() {
            // Process streaming data as it arrives
            if (xhr.readyState === XMLHttpRequest.LOADING) {
                root._processStreamingResponse();
            }

            if (xhr.readyState === XMLHttpRequest.DONE) {
                // Process any remaining data
                root._processStreamingResponse();

                if (xhr.status === 401) {
                    root.busy = false;
                    root.errorMessage = "Invalid API key";
                    root.responseError(root.errorMessage);
                } else if (xhr.status !== 200 && root.busy) {
                    root.busy = false;
                    let errorMsg = "Chat request failed";
                    try {
                        let errResponse = JSON.parse(xhr.responseText);
                        if (errResponse.error?.message) {
                            errorMsg = errResponse.error.message;
                        }
                    } catch (e) {}
                    root.errorMessage = errorMsg;
                    root.responseError(root.errorMessage);
                } else if (root.busy && root.currentResponse !== "") {
                    // Request completed but message_stop wasn't received
                    root.busy = false;
                    root.responseComplete(root.currentResponse);
                }

                root._chatRequest = null;
            }
        };

        xhr.open("POST", `${root.apiEndpoint}/v1/messages`);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("x-api-key", root.apiKey);
        xhr.setRequestHeader("anthropic-version", "2023-06-01");
        xhr.setRequestHeader("anthropic-dangerous-direct-browser-access", "true");
        xhr.send(JSON.stringify(payload));
    }

    function cancelRequest(): void {
        if (root._chatRequest) {
            root._chatRequest.abort();
            root._chatRequest = null;
            root.busy = false;
            root.errorMessage = "Request cancelled";
        }
    }

    function checkAvailability(): void {
        fetchModels();
    }
}
