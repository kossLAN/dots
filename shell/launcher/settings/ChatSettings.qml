pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs
import qs.widgets
import qs.services.chat

SettingsBacker {
    icon: "applications-chat-panel"
    enabled: ShellSettings.settings.chatEnabled
    summary: "Chat Settings"

    content: Item {
        id: menu

        property real cardHeight: 36

        ColumnLayout {
            spacing: 8
            anchors.fill: parent

            SettingsCard {
                title: "Conversation History"
                summary: `${ChatConnector.conversations.length} saved conversations`

                controls: Item {
                    implicitWidth: 100
                    implicitHeight: 32

                    StyledMouseArea {
                        radius: 4

                        anchors {
                            fill: parent
                            margins: 6
                        }

                        onClicked: {
                            let convs = ChatConnector.conversations.slice();

                            for (let conv of convs) {
                                ChatConnector.deleteConversation(conv.id);
                            }
                        }

                        StyledText {
                            text: "Clear History"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            anchors.fill: parent
                        } 
                    }
                }

                Layout.fillWidth: true
                Layout.preferredHeight: menu.cardHeight
            }

            Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
            }

            Repeater {
                model: ChatConnector.providers

                ColumnLayout {
                    id: providerSection

                    required property var modelData
                    required property int index

                    spacing: 8
                    Layout.fillWidth: true

                    SettingsCard {
                        title: providerSection.modelData.name

                        summary: {
                            if (providerSection.modelData.available)
                                return `${providerSection.modelData.models.length} models available`;

                            return providerSection.modelData.errorMessage || "Not available";
                        }

                        controls: RowLayout {
                            spacing: 8

                            Rectangle {
                                radius: 4
                                color: providerSection.modelData.available ? "#4ade80" : "#ef4444"
                                Layout.preferredWidth: 8
                                Layout.preferredHeight: 8
                            }

                            ToggleSwitch {
                                checked: providerSection.modelData.enabled

                                onCheckedChanged: {
                                    if (providerSection.modelData.enabled !== checked) {
                                        ChatConnector.setProviderEnabled(providerSection.modelData.providerId, checked);
                                    }
                                }
                            }
                        }

                        Layout.fillWidth: true
                        Layout.preferredHeight: menu.cardHeight
                    }

                    // Provider-specific settings
                    Loader {
                        active: providerSection.modelData.settings !== null
                        sourceComponent: providerSection.modelData.settings

                        Layout.fillWidth: true
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
