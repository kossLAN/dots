pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs
import qs.widgets

SettingsBacker {
    icon: "settings"

    summary: "General Settings"

    content: Item {
        id: menu

        property real cardHeight: 36

        ColumnLayout {
            spacing: 8
            anchors.fill: parent

            SettingsCard {
                title: "Bluetooth"
                summary: "Show bluetooth controls on the bar & in settings"

                controls: ToggleSwitch {
                    checked: ShellSettings.settings.bluetoothEnabled

                    onCheckedChanged: {
                        if (ShellSettings.settings.bluetoothEnabled !== checked) {
                            ShellSettings.settings.bluetoothEnabled = checked;
                        }
                    }
                }

                Layout.fillWidth: true
                Layout.preferredHeight: menu.cardHeight
            }

            SettingsCard {
                title: "Launcher"
                summary: "Disable the launcher/search button on the bar"

                controls: ToggleSwitch {
                    checked: ShellSettings.settings.searchEnabled

                    onCheckedChanged: {
                        if (ShellSettings.settings.searchEnabled !== checked) {
                            ShellSettings.settings.searchEnabled = checked;
                        }
                    }
                }

                Layout.fillWidth: true
                Layout.preferredHeight: menu.cardHeight
            }

            SettingsCard {
                title: "Debug"
                summary: "Disable the debug widgets in the shell"

                controls: ToggleSwitch {
                    checked: ShellSettings.settings.debugEnabled

                    onCheckedChanged: {
                        if (ShellSettings.settings.debugEnabled !== checked) {
                            ShellSettings.settings.debugEnabled = checked;
                        }
                    }
                }

                Layout.fillWidth: true
                Layout.preferredHeight: menu.cardHeight
            }

            SettingsCard {
                title: "Screen Recording"
                summary: "Show GPU Screen Recorder controls on the bar & in settings"

                controls: ToggleSwitch {
                    checked: ShellSettings.settings.gsrEnabled

                    onCheckedChanged: {
                        if (ShellSettings.settings.gsrEnabled !== checked) {
                            ShellSettings.settings.gsrEnabled = checked;
                        }
                    }
                }

                Layout.fillWidth: true
                Layout.preferredHeight: menu.cardHeight
            }

            SettingsCard {
                title: "LLM Chat"
                summary: "Show the LLM Chat in the launcher & settings"

                controls: ToggleSwitch {
                    checked: ShellSettings.settings.chatEnabled

                    onCheckedChanged: {
                        if (ShellSettings.settings.chatEnabled !== checked) {
                            ShellSettings.settings.chatEnabled = checked;
                        }
                    }
                }

                Layout.fillWidth: true
                Layout.preferredHeight: menu.cardHeight
            }

            SettingsCard {
                title: "Wallpaper Path"
                summary: "Change the path to your local wallpapers"

                controls: StyledTextInput {
                    text: ShellSettings.settings.wallpapersPath
                    width: 250

                    onAccepted: ShellSettings.settings.wallpapersPath = text
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
