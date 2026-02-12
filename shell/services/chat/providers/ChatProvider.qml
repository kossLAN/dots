import QtQuick
import Quickshell

Scope {
    id: root

    property bool enabled: false
    property string name: ""
    property string icon: ""
    property string providerId: "default"

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
    // history: array of {role: "user"|"assistant", content: string, images?: [{base64: string, mediaType: string}]}
    // images: optional array of image objects {base64: string, mediaType: string} for the current message
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
