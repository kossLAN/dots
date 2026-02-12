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
    name: "GitHub Copilot"
    icon: "root:resources/chat/github.svg"
    providerId: "github-copilot"
    apiEndpoint: "https://api.githubcopilot.com"

    // OAuth state (apiKey alias is used by ChatConnector for persistence)
    property alias apiKey: root.accessToken
    property string accessToken: ""
    property bool isAuthenticating: false
    property string authError: ""
    property string deviceCode: ""
    property string userCode: ""
    property string verificationUrl: ""
    property int pollInterval: 5

    // OAuth constants
    readonly property string clientId: "Ov23liNMs0UcKqo4ncy6"
    readonly property string deviceCodeUrl: "https://github.com/login/device/code"
    readonly property string accessTokenUrl: "https://github.com/login/oauth/access_token"

    available: accessToken !== ""
    supportsImages: currentModel.includes("claude") || currentModel.includes("gpt-4") || currentModel.includes("gpt-5") || currentModel.includes("gemini")

    // Hardcoded model list - Copilot API doesn't have a models endpoint
    // Update this list when GitHub adds new models
    // See: https://docs.github.com/en/copilot/reference/ai-models/supported-models
    property var copilotModels: [
        "claude-opus-4.6",
        "claude-opus-4.5",
        "gpt-5.3-codex",
        "gpt-5.2-codex",
        "gpt-5.1-codex",
        "gpt-5.1-codex-mini",
        "gpt-5.1-codex-max",
        "gpt-5",
        "gpt-5.1",
        "gpt-5.2",
        "claude-sonnet-4",
        "claude-sonnet-4.5",
        "claude-haiku-4.5",
        "gpt-4.1",
        "gpt-5-mini",
        "gemini-2.5-pro",
        "gemini-3-flash",
        "gemini-3-pro",
        "grok-code-fast-1",
        "raptor-mini"
    ]

    settings: ColumnLayout {
        spacing: 8

        SettingsCard {
            visible: root.accessToken === ""
            title: "Authentication"
            summary: root.isAuthenticating ? "Waiting for authorization..." : "Login with GitHub to use Copilot"

            controls: RowLayout {
                spacing: 8

                StyledButton {
                    visible: !root.isAuthenticating
                    color: ShellSettings.colors.active.alternateBase
                    onClicked: root.startOAuthFlow()

                    implicitWidth: loginText.implicitWidth + 24
                    Layout.fillHeight: true

                    StyledText {
                        id: loginText
                        text: "Login with GitHub"
                        anchors.centerIn: parent
                    }
                }

                StyledButton {
                    visible: root.isAuthenticating
                    color: ShellSettings.colors.active.alternateBase
                    onClicked: root.cancelAuth()

                    implicitWidth: cancelText.implicitWidth + 24
                    Layout.fillHeight: true

                    StyledText {
                        id: cancelText
                        text: "Cancel"
                        anchors.centerIn: parent
                    }
                }
            }

            Layout.fillWidth: true
            Layout.preferredHeight: 36
        }

        // Show device code during auth
        SettingsCard {
            visible: root.isAuthenticating && root.userCode !== ""
            title: "Enter Code"
            summary: "Go to " + root.verificationUrl + " and enter: " + root.userCode

            controls: StyledButton {
                color: ShellSettings.colors.active.alternateBase
                implicitWidth: openBrowserText.implicitWidth + 24
                implicitHeight: parent.height

                onClicked: Qt.openUrlExternally(root.verificationUrl)

                StyledText {
                    id: openBrowserText
                    text: "Open Browser"
                    anchors.centerIn: parent
                }
            }

            Layout.fillWidth: true
            Layout.preferredHeight: 36
        }

        SettingsCard {
            visible: root.accessToken !== ""
            title: "Status"
            summary: "Authenticated with GitHub Copilot"

            controls: StyledButton {
                color: ShellSettings.colors.active.alternateBase
                implicitWidth: logoutText.implicitWidth + 24
                implicitHeight: parent.height

                onClicked: root.logout()

                StyledText {
                    id: logoutText
                    text: "Logout"
                    anchors.centerIn: parent
                }
            }

            Layout.fillWidth: true
            Layout.preferredHeight: 36
        }

        Text {
            visible: root.authError !== ""
            text: root.authError
            color: ShellSettings.colors.extra.close 
            font.pixelSize: 12
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }
    }

    // Track current XMLHttpRequest for chat (to support cancellation)
    property var _chatRequest: null
    property int _lastProcessedIndex: 0

    // Timer for OAuth polling
    Timer {
        id: pollTimer
        interval: root.pollInterval * 1000
        repeat: true
        running: false
        onTriggered: root.pollForToken()
    }

    function startOAuthFlow(): void {
        root.isAuthenticating = true;
        root.authError = "";
        root.userCode = "";
        root.deviceCode = "";

        let xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        let response = JSON.parse(xhr.responseText);
                        root.deviceCode = response.device_code;
                        root.userCode = response.user_code;
                        root.verificationUrl = response.verification_uri;
                        root.pollInterval = response.interval || 5;

                        // Start polling for token
                        pollTimer.start();

                        // Auto-open browser
                        Qt.openUrlExternally(root.verificationUrl);
                    } catch (e) {
                        root.authError = "Failed to parse device code response";
                        root.isAuthenticating = false;
                    }
                } else {
                    root.authError = "Failed to start authentication";
                    root.isAuthenticating = false;
                }
            }
        };

        xhr.open("POST", root.deviceCodeUrl);
        xhr.setRequestHeader("Accept", "application/json");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(JSON.stringify({
            client_id: root.clientId,
            scope: "read:user"
        }));
    }

    function pollForToken(): void {
        let xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        let response = JSON.parse(xhr.responseText);

                        if (response.access_token) {
                            // Success!
                            root.accessToken = response.access_token;
                            root.isAuthenticating = false;
                            root.userCode = "";
                            root.deviceCode = "";
                            pollTimer.stop();

                            // Save token
                            ChatConnector.setProviderApiKey(root.providerId, response.access_token);

                            // Load models
                            root.fetchModels();
                            return;
                        }

                        if (response.error === "authorization_pending") {
                            // Keep polling
                            return;
                        }

                        if (response.error === "slow_down") {
                            // Increase interval
                            root.pollInterval = (response.interval || root.pollInterval) + 5;
                            pollTimer.interval = root.pollInterval * 1000;
                            return;
                        }

                        if (response.error === "expired_token") {
                            root.authError = "Authorization expired. Please try again.";
                            root.cancelAuth();
                            return;
                        }

                        if (response.error === "access_denied") {
                            root.authError = "Authorization denied.";
                            root.cancelAuth();
                            return;
                        }

                        if (response.error) {
                            root.authError = "Authorization error: " + response.error;
                            root.cancelAuth();
                            return;
                        }
                    } catch (e) {
                        // Keep polling on parse errors
                    }
                }
            }
        };

        xhr.open("POST", root.accessTokenUrl);
        xhr.setRequestHeader("Accept", "application/json");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(JSON.stringify({
            client_id: root.clientId,
            device_code: root.deviceCode,
            grant_type: "urn:ietf:params:oauth:grant-type:device_code"
        }));
    }

    function cancelAuth(): void {
        pollTimer.stop();
        root.isAuthenticating = false;
        root.userCode = "";
        root.deviceCode = "";
    }

    function logout(): void {
        root.accessToken = "";
        root.available = false;
        root.models = [];
        root.currentModel = "";
        ChatConnector.setProviderApiKey(root.providerId, "");
    }

    function _processStreamingResponse(): void {
        if (!_chatRequest) return;

        let responseText = _chatRequest.responseText;
        if (responseText.length <= _lastProcessedIndex) return;

        // Get new data since last processed
        let newData = responseText.substring(_lastProcessedIndex);
        let lines = newData.split("\n");

        // Process complete lines
        for (let i = 0; i < lines.length - 1; i++) {
            let line = lines[i].trim();
            if (line === "") continue;

            // SSE format: lines starting with "data: "
            if (line.startsWith("data: ")) {
                let jsonStr = line.substring(6);
                if (jsonStr === "[DONE]") {
                    root.busy = false;
                    root.responseComplete(root.currentResponse);
                    root._chatRequest = null;
                    return;
                }

                try {
                    let event = JSON.parse(jsonStr);

                    // OpenAI-style streaming
                    if (event.choices && event.choices.length > 0) {
                        let choice = event.choices[0];
                        if (choice.delta && choice.delta.content) {
                            let chunk = choice.delta.content;
                            root.currentResponse += chunk;
                            root.responseChunk(chunk);
                        }
                        if (choice.finish_reason === "stop") {
                            root.busy = false;
                            root.responseComplete(root.currentResponse);
                            root._chatRequest = null;
                            return;
                        }
                    }

                    if (event.error) {
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

        // Update last processed index
        let lastNewlineIndex = newData.lastIndexOf("\n");
        if (lastNewlineIndex >= 0) {
            _lastProcessedIndex += lastNewlineIndex + 1;
        }
    }

    function fetchModels(): void {
        if (root.accessToken === "") {
            root.models = [];
            root.available = false;
            return;
        }

        let xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        let response = JSON.parse(xhr.responseText);
                        let modelIds = [];

                        // Handle array response (list of model objects)
                        if (Array.isArray(response)) {
                            for (let model of response) {
                                if (model.id) {
                                    modelIds.push(model.id);
                                } else if (model.name) {
                                    modelIds.push(model.name);
                                }
                            }
                        }
                        // Handle object with models/data array
                        else if (response.models && Array.isArray(response.models)) {
                            for (let model of response.models) {
                                if (model.id) {
                                    modelIds.push(model.id);
                                }
                            }
                        }
                        else if (response.data && Array.isArray(response.data)) {
                            for (let model of response.data) {
                                if (model.id) {
                                    modelIds.push(model.id);
                                }
                            }
                        }

                        if (modelIds.length > 0) {
                            root.models = modelIds;
                        } else {
                            // Fallback to hardcoded list
                            root.models = root.copilotModels;
                        }
                    } catch (e) {
                        console.warn("GitHub Copilot: Failed to parse models response, using fallback");
                        root.models = root.copilotModels;
                    }
                } else {
                    // API doesn't support models endpoint, use fallback
                    console.log("GitHub Copilot: Models endpoint returned " + xhr.status + ", using fallback list");
                    root.models = root.copilotModels;
                }

                root.available = root.accessToken !== "";

                if (root.models.length > 0 && root.currentModel === "") {
                    root.currentModel = root.models[0];
                }

                root.modelsLoaded(root.models);
                root.errorMessage = "";
            }
        };

        xhr.open("GET", `${root.apiEndpoint}/models`);
        xhr.setRequestHeader("Authorization", `Bearer ${root.accessToken}`);
        xhr.setRequestHeader("Accept", "application/json");
        xhr.setRequestHeader("Editor-Version", "Nixi/1.0");
        xhr.send();
    }

    // Build content array for messages with images (OpenAI format)
    function _buildContentArray(text, images) {
        let content = [];

        // Add text first
        content.push({
            type: "text",
            text: text
        });

        // Add images if present
        if (images && Array.isArray(images)) {
            for (let img of images) {
                content.push({
                    type: "image_url",
                    image_url: {
                        url: `data:${img.mediaType};base64,${img.base64}`
                    }
                });
            }
        }

        return content;
    }

    function sendMessage(message, history, images = null) {
        if (root.busy) {
            console.warn("GitHub Copilot: Already processing a request");
            return;
        }

        if (root.currentModel === "") {
            root.errorMessage = "No model selected";
            root.responseError(root.errorMessage);
            return;
        }

        if (root.accessToken === "") {
            root.errorMessage = "Not authenticated";
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

        // Build current message
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
            messages: messages,
            stream: true
        };

        let xhr = new XMLHttpRequest();
        root._chatRequest = xhr;

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.LOADING) {
                root._processStreamingResponse();
            }

            if (xhr.readyState === XMLHttpRequest.DONE) {
                root._processStreamingResponse();

                if (xhr.status === 401) {
                    root.busy = false;
                    root.errorMessage = "Authentication expired. Please login again.";
                    root.accessToken = "";
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
                    root.busy = false;
                    root.responseComplete(root.currentResponse);
                }

                root._chatRequest = null;
            }
        };

        xhr.open("POST", `${root.apiEndpoint}/chat/completions`);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Authorization", `Bearer ${root.accessToken}`);
        xhr.setRequestHeader("Openai-Intent", "conversation-edits");
        xhr.setRequestHeader("Editor-Version", "Nixi/1.0");

        // Add vision header if we have images
        if (images && images.length > 0) {
            xhr.setRequestHeader("Copilot-Vision-Request", "true");
        }

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
        // Try to restore token from saved state
        let savedToken = ChatConnector.getProviderApiKey(root.providerId);
        if (savedToken && savedToken !== "") {
            root.accessToken = savedToken;
            root.fetchModels();
        }
    }
}
