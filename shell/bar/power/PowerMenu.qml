pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Widgets
import Quickshell.Services.UPower
import qs.widgets
import qs.bar
import qs

// todo: redo the tray icon handling
StyledMouseArea {
    id: root
    implicitWidth: height + 8 // for margin
    visible: UPower.displayDevice.isLaptopBattery
    onClicked: showMenu = !showMenu

    required property var bar
    property bool showMenu: false

    // Helper function to format time in seconds to human readable
    function formatTime(seconds) {
        if (seconds <= 0 || !isFinite(seconds))
            return "calculating...";

        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);

        if (hours > 0) {
            return hours + "h " + minutes + "m";
        } else {
            return minutes + "m";
        }
    }

    // Helper function to get battery color based on percentage and state
    function getBatteryColor() {
        const device = UPower.displayDevice;
        const percentage = device.percentage;

        // Charging - use a blue/cyan color
        if (device.state === 1) { // Charging state
            return ShellSettings.colors.accent;
        }

        // Critical battery - red
        if (percentage < 0.10) {
            return "#ef5350";
        } else
        // Low battery - orange
        if (percentage < 0.20) {
            return "#ff9800";
        }
        // Normal - use surface color
        return ShellSettings.colors.surface;
    }

    Item {
        implicitWidth: parent.height
        implicitHeight: parent.height
        anchors.centerIn: parent
        layer.enabled: true
        layer.effect: OpacityMask {
            source: Rectangle {
                width: root.width
                height: root.height
                color: "white"
            }

            maskSource: IconImage {
                implicitSize: root.width
                source: "root:resources/battery/battery.svg"
            }
        }

        Rectangle {
            id: batteryBackground
            color: Qt.color(ShellSettings.colors.inactive_translucent).lighter(4)
            opacity: 0.75
            anchors {
                fill: parent
                margins: 2
            }
        }

        Rectangle {
            id: batteryPercentage
            width: (parent.width - 4) * UPower.displayDevice.percentage
            color: getBatteryColor()

            anchors {
                left: batteryBackground.left
                top: batteryBackground.top
                bottom: batteryBackground.bottom
            }

            // Animated charging indicator
            SequentialAnimation on opacity {
                running: UPower.displayDevice.state === 1 // Charging
                loops: Animation.Infinite
                NumberAnimation {
                    to: 0.5
                    duration: 1000
                }
                NumberAnimation {
                    to: 1.0
                    duration: 1000
                }
            }
        }
    }

    property PopupItem menu: PopupItem {
        owner: root
        popup: root.bar.popup
        show: root.showMenu
        onClosed: root.showMenu = false

        implicitWidth: 320
        implicitHeight: contentColumn.implicitHeight + 16

        ColumnLayout {
            id: contentColumn
            anchors {
                fill: parent
                margins: 8
            }
            spacing: 12

            // Battery status section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                StyledText {
                    text: "Battery Status"
                    font.weight: Font.Bold
                    font.pixelSize: 14
                }

                // Percentage and state
                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Charge:"
                        Layout.preferredWidth: 100
                    }

                    StyledText {
                        text: Math.round(UPower.displayDevice.percentage * 100) + "%"
                        font.weight: Font.Bold
                    }
                }

                // State
                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "State:"
                        Layout.preferredWidth: 100
                    }

                    StyledText {
                        text: {
                            switch (UPower.displayDevice.state) {
                            case 0:
                                return "Unknown";
                            case 1:
                                return "Charging";
                            case 2:
                                return "Discharging";
                            case 3:
                                return "Empty";
                            case 4:
                                return "Fully charged";
                            case 5:
                                return "Pending charge";
                            case 6:
                                return "Pending discharge";
                            default:
                                return "Unknown";
                            }
                        }
                        color: UPower.displayDevice.state === 1 ? ShellSettings.colors.accent : ShellSettings.colors.foreground
                    }
                }

                // Time to full (when charging)
                RowLayout {
                    Layout.fillWidth: true
                    visible: UPower.displayDevice.state === 1 && UPower.displayDevice.timeToFull > 0

                    StyledText {
                        text: "Time to full:"
                        Layout.preferredWidth: 100
                    }

                    StyledText {
                        text: formatTime(UPower.displayDevice.timeToFull)
                    }
                }

                // Time to empty (when discharging)
                RowLayout {
                    Layout.fillWidth: true
                    visible: UPower.displayDevice.state === 2 && UPower.displayDevice.timeToEmpty > 0

                    StyledText {
                        text: "Time remaining:"
                        Layout.preferredWidth: 100
                    }

                    StyledText {
                        text: formatTime(UPower.displayDevice.timeToEmpty)
                    }
                }

                // Energy information
                RowLayout {
                    Layout.fillWidth: true
                    visible: UPower.displayDevice.energy > 0

                    StyledText {
                        text: "Energy:"
                        Layout.preferredWidth: 100
                    }

                    StyledText {
                        text: UPower.displayDevice.energy.toFixed(2) + " Wh / " + UPower.displayDevice.energyCapacity.toFixed(2) + " Wh"
                        font.pixelSize: 12
                    }
                }

                // Power draw/charge rate
                RowLayout {
                    Layout.fillWidth: true
                    visible: Math.abs(UPower.displayDevice.changeRate) > 0.1

                    StyledText {
                        text: UPower.displayDevice.state === 1 ? "Charge rate:" : "Power draw:"
                        Layout.preferredWidth: 100
                    }

                    StyledText {
                        text: Math.abs(UPower.displayDevice.changeRate).toFixed(2) + " W"
                    }
                }

                // Battery health
                RowLayout {
                    Layout.fillWidth: true
                    visible: UPower.displayDevice.healthSupported

                    StyledText {
                        text: "Health:"
                        Layout.preferredWidth: 100
                    }

                    StyledText {
                        text: Math.round(UPower.displayDevice.healthPercentage * 100) + "%"
                        color: {
                            const health = UPower.displayDevice.healthPercentage;
                            if (health > 0.8)
                                return "#4caf50";
                            else if (health > 0.6)
                                return "#ff9800";
                            else
                                return "#ef5350";
                        }
                    }
                }

                // Model info
                RowLayout {
                    Layout.fillWidth: true
                    visible: UPower.displayDevice.model !== ""

                    StyledText {
                        text: "Model:"
                        Layout.preferredWidth: 100
                    }

                    StyledText {
                        text: UPower.displayDevice.model
                        font.pixelSize: 11
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }

            // Power profile section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                StyledText {
                    text: "Power Profile"
                    font.weight: Font.Bold
                    font.pixelSize: 14
                }

                OptionSlider {
                    Layout.fillWidth: true
                    values: ["Power Save", "Balanced", "Performance"]
                    index: PowerProfiles.profile
                    onIndexChanged: PowerProfiles.profile = this.index
                }
            }
        }
    }
}
