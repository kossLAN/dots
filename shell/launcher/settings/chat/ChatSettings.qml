pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs
import qs.widgets
import qs.services.chat
import qs.launcher.settings

SettingsBacker {
    icon: "applications-chat-panel"
    enabled: ShellSettings.settings.chatEnabled
    summary: "Chat Settings"
    label: "Chat"

    content: Item {
        id: menu

        ColumnLayout {
            spacing: 0
            anchors.fill: parent

            SettingsCard {
                title: "Conversation History"
                summary: `${ChatConnector.conversations.length} saved conversations`

                Layout.fillWidth: true
                Layout.preferredHeight: 48

                controls: Item {
                    implicitWidth: 100

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

                    spacing: 4
                    Layout.fillWidth: true

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 24 
                        Layout.margins: 8

                        RowLayout {
                            spacing: 0
                            anchors.fill: parent

                            ProviderCard {
                                provider: providerSection.modelData
                                Layout.fillWidth: true
                                Layout.fillHeight: true 
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
                    }

                    // Provider-specific settings
                    Loader {
                        active: providerSection.modelData.settings !== null
                        sourceComponent: providerSection.modelData.settings

                        Layout.fillWidth: true
                    }

                    Separator {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        Layout.topMargin: 4
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
