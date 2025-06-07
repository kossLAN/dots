pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs
import qs.widgets

Item {
    Layout.fillWidth: true
    Layout.fillHeight: true

    ColumnLayout {
        spacing: 4

        anchors {
            fill: parent
            margins: 12
        }

        RowLayout {
            spacing: 8
            Layout.fillWidth: true

            // Bar Height
            StyledRectangle {
                color: ShellSettings.colors.active.base

                Layout.fillWidth: true
                Layout.minimumWidth: 280
                Layout.preferredHeight: 56

                ColumnLayout {
                    spacing: 2

                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                        leftMargin: 12
                    }

                    StyledText {
                        text: "Bar Height"
                        font.pointSize: 9
                    }

                    StyledText {
                        text: "Height of the status bar"
                        font.pointSize: 9
                        opacity: 0.7
                    }
                }

                RowLayout {
                    spacing: 8

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 12
                    }

                    StyledSlider {
                        id: barHeightSlider
                        from: 20
                        to: 50
                        stepSize: 1
                        value: ShellSettings.sizing.barHeight

                        Layout.preferredWidth: 200

                        onMoved: ShellSettings.sizing.barHeight = value
                    }

                    StyledText {
                        text: ShellSettings.sizing.barHeight + "px"
                        font.pointSize: 9
                        Layout.preferredWidth: 30
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }

        // Bluetooth Toggle
        StyledRectangle {
            color: ShellSettings.colors.active.base

            Layout.fillWidth: true
            Layout.preferredHeight: 56

            ColumnLayout {
                spacing: 2
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: 12
                }

                StyledText {
                    text: "Bluetooth"
                    font.pointSize: 9
                }

                StyledText {
                    text: "Show Bluetooth controls"
                    font.pointSize: 9
                    opacity: 0.7
                }
            }

            ToggleSwitch {
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
        }

        // Search Toggle
        StyledRectangle {
            color: ShellSettings.colors.active.base

            Layout.fillWidth: true
            Layout.preferredHeight: 56

            ColumnLayout {
                spacing: 2

                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: 12
                }

                StyledText {
                    text: "Launcher"
                    font.pointSize: 9
                }

                StyledText {
                    text: "Disable the launcher/search button on the bar"
                    font.pointSize: 9
                    opacity: 0.7
                }
            }

            ToggleSwitch {
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
        }

        // Debug Toggle
        StyledRectangle {
            color: ShellSettings.colors.active.base

            Layout.fillWidth: true
            Layout.preferredHeight: 56

            ColumnLayout {
                spacing: 2
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: 12
                }

                StyledText {
                    text: "Debug"
                    font.pointSize: 9
                }

                StyledText {
                    text: "Show debug widgets"
                    font.pointSize: 9
                    opacity: 0.7
                }
            }

            ToggleSwitch {
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
        }

        // Wallpapers Path
        StyledRectangle {
            color: ShellSettings.colors.active.base

            Layout.fillWidth: true
            Layout.preferredHeight: 56

            ColumnLayout {
                spacing: 2
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: 12
                }

                StyledText {
                    text: "Wallpapers Path"
                    font.pointSize: 9
                }

                StyledText {
                    text: "Additional folder for wallpapers"
                    font.pointSize: 9
                    opacity: 0.7
                }
            }

            StyledTextInput {
                text: ShellSettings.settings.wallpapersPath
                takeFocus: false
                width: 250
                height: 28

                onAccepted: ShellSettings.settings.wallpapersPath = text

                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    rightMargin: 12
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
