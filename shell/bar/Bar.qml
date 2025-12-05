import QtQuick
import QtQuick.Layouts
import Quickshell
import "power"
import "volume"
import "systray"
import "bluetooth"
// import qs.widgets
import qs

Variants {
    model: Quickshell.screens

    delegate: PanelWindow {
        id: root
        color: ShellSettings.colors.background
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
                    Layout.preferredWidth: height
                }

                NiriWorkspaces {
                    screen: root.screen
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                }

                // ActiveWindow {
                //     id: activeWindow
                //     Layout.preferredWidth: 400
                // }
            }

            // PowerMenu {
            //     bar: root
            //     Layout.fillHeight: true
            // }

            // Right side of bar
            RowLayout {
                spacing: 5
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignRight

                SysTray {
                    bar: root
                    Layout.fillHeight: true
                }

                VolumeIndicator {
                    bar: root
                    Layout.preferredWidth: this.height
                    Layout.fillHeight: true
                }

                BluetoothMenu {
                    bar: root
                    Layout.preferredWidth: this.height
                    Layout.fillHeight: true
                }

                PowerMenu {
                    bar: root
                    Layout.fillHeight: true
                }

                // Widgets.Separator {
                //     Layout.leftMargin: 5
                //     Layout.rightMargin: 5
                // }

                Clock {
                    bar: root
                    Layout.leftMargin: 5
                }
            }
        }
    }
}
