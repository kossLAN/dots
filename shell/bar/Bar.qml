import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import qs
import qs.notifications

import qs.bar.power
import qs.bar.volume
import qs.bar.systray
import qs.bar.bluetooth
import qs.bar.wifi
import qs.bar.notifications
import qs.bar.mpris
import qs.bar.debug
import qs.bar.gsr

Variants {
    model: Quickshell.screens

    delegate: PanelWindow {
        id: root
        color: ShellSettings.colors.active.window
        implicitHeight: ShellSettings.sizing.barHeight
        screen: modelData

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "shell:bar"

        required property var modelData

        anchors {
            top: true
            left: true
            right: true
        }

        readonly property Popup popup: Popup {
            bar: root
            onPopupOpened: Notifications.blockToasts = true
            onPopupClosed: Notifications.blockToasts = false
        }

        RowLayout {
            spacing: 0

            anchors {
                fill: parent
                leftMargin: 5
                rightMargin: 5
            }

            Item {
                id: leftSide
                clip: true

                Layout.fillWidth: true
                Layout.fillHeight: true

                Workspaces {
                    screen: root.screen
                    anchors.fill: parent
                }
            }

            MprisMenu {
                bar: root
                Layout.maximumWidth: (root.width / 3)
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
            }

            Item {
                clip: true

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignRight

                RowLayout {
                    spacing: 5
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height

                    NotificationSpawner {
                        Layout.preferredWidth: this.height
                        Layout.fillHeight: true
                    }

                    SysTray {
                        bar: root
                        Layout.fillHeight: true
                    }

                    SearchButton {
                        Layout.preferredWidth: this.height
                        Layout.fillHeight: true
                    }

                    PowerMenu {
                        bar: root
                        Layout.preferredWidth: this.height
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

                    GsrMenu {
                        bar: root
                        Layout.preferredWidth: this.height
                        Layout.fillHeight: true
                    }

                    WifiMenu {
                        bar: root
                        Layout.preferredWidth: this.height
                        Layout.fillHeight: true
                    }

                    NotificationsCenter {
                        bar: root
                        Layout.fillHeight: true
                    }

                    TimeDisplay {
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
}
