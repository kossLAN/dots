pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs
import qs.widgets

SettingsBacker {
    icon: "settings"

    content: Item {
        id: menu

        property real cardHeight: 36

        ColumnLayout {
            spacing: 4
            anchors.fill: parent

            SettingsCard {
                title: "Bluetooth"
                summary: "Show bluetooth controls on the bar & in settings"

                controls: ToggleSwitch {
                    checked: ShellSettings.settings.bluetoothEnabled

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 12
                    }

                    onCheckedChanged: {
                        if (ShellSettings.settings.bluetoothEnabled !== checked) {
                            ShellSettings.settings.bluetoothEnabled = checked;
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

            SettingsCard {
                title: "Launcher"
                summary: "Disable the launcher/search button on the bar"

                controls: ToggleSwitch {
                    checked: ShellSettings.settings.searchEnabled

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 12
                    }

                    onCheckedChanged: {
                        if (ShellSettings.settings.searchEnabled !== checked) {
                            ShellSettings.settings.searchEnabled = checked;
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

            SettingsCard {
                title: "Debug"
                summary: "Disable the debug widgets in the shell"

                controls: ToggleSwitch {
                    checked: ShellSettings.settings.debugEnabled

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 12
                    }

                    onCheckedChanged: {
                        if (ShellSettings.settings.debugEnabled !== checked) {
                            ShellSettings.settings.debugEnabled = checked;
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

            SettingsCard {
                title: "Wallpaper Path"
                summary: "Change the path to your local wallpapers"

                controls: StyledTextInput {
                    text: ShellSettings.settings.wallpapersPath
                    width: 250

                    onAccepted: ShellSettings.settings.wallpapersPath = text

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 12
                    }
                }

                Layout.fillWidth: true
                Layout.preferredHeight: menu.cardHeight
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
