import QtQuick
import QtQuick.Layouts
import Quickshell
// import "power"
// import "volume"
import "systray"
// import qs.widgets
import qs

Variants {
    model: Quickshell.screens

    delegate: PanelWindow {
        id: root
        color: ShellSettings.colors.surface_translucent
        implicitHeight: ShellSettings.sizing.barHeight
        screen: modelData

        required property var modelData

        anchors {
            top: true
            left: true
            right: true
        }

        readonly property Popup popup: Popup {
            bar: root
        }

        RowLayout {
            spacing: 0

            anchors {
                fill: parent
                leftMargin: 5
                rightMargin: 5
            }

            // Left side of bar
            RowLayout {
                spacing: 15
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignLeft

                Workspaces {
                    screen: root.screen
                    Layout.fillHeight: true
                }

                ActiveWindow {
                    id: activeWindow
                    Layout.preferredWidth: 400
                }
            }

            // Right side of bar
            RowLayout {
                spacing: 10
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignRight

                SysTray {
                    id: sysTray
                    bar: root
                    Layout.fillHeight: true
                }

                // VolumeIndicator {
                //     id: volumeIndicator
                //     popup: root.popup
                //     Layout.preferredWidth: this.height
                //     Layout.fillHeight: true
                //     Layout.topMargin: 2
                //     Layout.bottomMargin: 2
                // }

                // BatteryIndicator {
                //     id: batteryIndicator
                //     Layout.fillHeight: true
                // }

                // Widgets.Separator {
                //     Layout.leftMargin: 5
                //     Layout.rightMargin: 5
                // }

                Clock {
                    id: clock
                    color: ShellSettings.colors.active
                }
            }
        }
    }
}
