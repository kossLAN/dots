pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.widgets
import qs.services.chat
import qs.launcher.settings

AnthropicProvider {
    id: root

    enabled: true
    name: "Minimax"
    icon: "root:resources/chat/minimax.png"
    providerId: "minimax"
    apiEndpoint: "https://api.minimax.io/anthropic"

    property string apiVersion: "2023-06-01"
    property string authHeader: "Authorization"
    property string authPrefix: "Bearer"

    available: false
    supportsImages: false

    settings: ColumnLayout {
        spacing: 4

        SettingsCard {
            title: "API Key"
            summary: "Your Minimax API key"

            controls: StyledTextInput {
                text: root.apiKey
                width: 250
                placeholderText: "Enter your API key"
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

    // No API that allows you to get the models list unfortunately.
    // https://platform.minimax.io/docs/api-reference/text-anthropic-api#supported-models
    property list<string> models: [
        "MiniMax-M2.5",
        "MiniMax-M2.1",
    ]

    function fetchModels(): void {
        root.available = root.apiKey !== "";

        if (root.available && root.currentModel === "") {
            root.currentModel = root.models[0];
        }

        root.modelsLoaded(root.models);
    }

    function checkAvailability(): void {
        fetchModels();
    }
}
