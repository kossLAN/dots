pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets

import qs
import qs.widgets
import qs.filepicker

SettingsBacker {
    icon: "settings"

    summary: "General Settings"
    label: "General"

    content: Item {
        id: menu

        property real cardHeight: 36

        property string hostname: ""

        Process {
            id: hostnameProc
            command: ["hostname"]
            running: true
            stdout: SplitParser {
                onRead: data => menu.hostname = data.trim()
            }
        }

        Process {
            id: copyProfilePicture
            property string dest: ""
            onExited: (exitCode, exitStatus) => {
                if (exitCode === 0)
                    ShellSettings.profilePicture = "file://" + dest;
            }
        }

        FilePicker {
            id: profilePicturePicker
            nameFilters: ["Images (*.png *.jpg *.jpeg *.webp)"]

            onAccepted: {
                const source = selectedFile.toString().replace("file://", "");
                const ext = source.substring(source.lastIndexOf("."));
                const dest = "/etc/nixi/profile-picture" + ext;
                copyProfilePicture.dest = dest;
                copyProfilePicture.command = ["cp", source, dest];
                copyProfilePicture.running = true;
            }
        }

        ColumnLayout {
            spacing: 0
            anchors.fill: parent

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: header.implicitHeight + 16

                RowLayout {
                    id: header
                    spacing: 16

                    anchors { 
                        fill: parent
                        margins: 8
                    }

                    Item {
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48

                        Item {
                            id: profileImage
                            anchors.fill: parent

                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: profileImage.width
                                    height: profileImage.height
                                    radius: width / 2
                                    color: "black"
                                }
                            }

                            Image {
                                source: ShellSettings.profilePicture
                                anchors.fill: parent
                            }
                        }

                        StyledButton {
                            color: ShellSettings.colors.active.base
                            radius: 4 
                            implicitWidth: 20
                            implicitHeight: 20

                            anchors {
                                bottom: parent.bottom
                                right: parent.right
                                bottomMargin: -4
                                rightMargin: -4
                            }

                            onClicked: profilePicturePicker.open()

                            IconImage {
                                source: Quickshell.iconPath("edit-image")

                                anchors {
                                    fill: parent
                                    margins: 0
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        StyledText {
                            text: Quickshell.env("USER") || "User"
                            font.pointSize: 14
                            font.bold: true
                        }

                        StyledText {
                            text: menu.hostname
                            font.pointSize: 10
                            opacity: 0.6
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }

            Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
            }

            ColumnLayout {
                spacing: 8
                Layout.fillWidth: true
                Layout.fillHeight: true

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

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }
}
