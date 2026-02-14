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

    content: Item {
        id: menu

        property real cardHeight: 36

        ColumnLayout {
            spacing: 0
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
                Layout.margins: 8
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

                    RowLayout {
                        spacing: 8
                        Layout.fillWidth: true
                        Layout.preferredHeight: menu.cardHeight
                        Layout.margins: 8

                        ProviderCard {
                            provider: providerSection.modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: menu.cardHeight
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

                    // Provider-specific settings
                    Loader {
                        active: providerSection.modelData.settings !== null
                        sourceComponent: providerSection.modelData.settings

                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                    }

                    Separator {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
