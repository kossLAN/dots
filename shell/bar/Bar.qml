import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.notifications
import qs.bar.power
import qs.bar.volume
import qs.bar.systray
import qs.bar.bluetooth

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

            // Closing logic for windows that aren't part of the Popup system.
            onPopupClosed: {
                if (NotificationCenter.notificationsOpen) {
                    NotificationCenter.api.close();
                }
            }
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
                    // Layout.preferredWidth: height
                }

                // ActiveWindow {
                //     id: activeWindow
                //     Layout.preferredWidth: 400
                // }
            }

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

                Clock {
                    bar: root
                    Layout.leftMargin: 5
                }
            }
        }
    }
}
