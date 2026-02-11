import QtQuick
import Quickshell

Scope {
    id: root

    property bool enabled: false
    property string name: "Provider"
    property string icon: "chat"
    property string providerId: "generic"

    property string apiEndpoint: ""
    property string currentModel: ""
    property list<string> models: []

    property bool available: false
    property bool busy: false
    property string errorMessage: ""

    property string currentResponse: ""

    // Whether this provider supports image uploads (vision capability)
    property bool supportsImages: false

    // Settings component for this provider (to be overridden)
    property Component settings: null

    signal responseChunk(string chunk)
    signal responseComplete(string fullResponse)
    signal responseError(string error)
    signal modelsLoaded(list<string> models)

    // Abstract functions to be implemented by providers
    // Fetches available models from the provider
    function fetchModels(): void {
        console.error(`${name}: fetchModels() not implemented`);
    }

    // Sends a message with conversation history, streams response
    // history: array of {role: "user"|"assistant", content: string, images?: string[]}
    // images: optional array of base64-encoded image data for the current message
    function sendMessage(message, history, images = null) {
        console.error(`${name}: sendMessage() not implemented`);
    }

    // Cancels the current request
    function cancelRequest(): void {
        console.error(`${name}: cancelRequest() not implemented`);
    }

    // Checks if the provider is available/configured
    function checkAvailability(): void {
        console.error(`${name}: checkAvailability() not implemented`);
    }
}
