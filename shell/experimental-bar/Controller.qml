pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import "power"
import "volume"
import "systray" as SysTray
import "popups" as Popup
import "../widgets"
import ".."

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        Border {
            id: border
            screen: modelData

            required property var modelData

            top: RowLayout {
                id: top
                spacing: 0

                anchors {
                    fill: parent
                    leftMargin: 8
                    rightMargin: 8
                }

                Popup.MenuWindow {
                    id: popupWindow
                    bar: border.topWindow
                }

                RowLayout {
                    spacing: 5
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Workspaces {
                        screen: border.screen
                        Layout.fillHeight: true
                    }

                    Separator {
                        visible: activeWindow.visible
                        Layout.leftMargin: 5
                        Layout.rightMargin: 5
                    }

                    ActiveWindow {
                        id: activeWindow
                        Layout.preferredWidth: 400
                    }
                }

                RowLayout {
                    spacing: 5
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignRight

                    SysTray.SysTray {
                        id: sysTray
                        popup: popupWindow
                        Layout.fillHeight: true
                    }

                    VolumeIndicator {
                        id: volumeIndicator
                        popup: popupWindow
                        Layout.preferredWidth: this.height
                        Layout.fillHeight: true
                        Layout.topMargin: 2
                        Layout.bottomMargin: 2
                    }

                    BatteryIndicator {
                        id: batteryIndicator
                        popup: popupWindow
                        Layout.fillHeight: true
                    }

                    Separator {
                        // Layout.leftMargin: 5
                        Layout.rightMargin: 5
                    }

                    Clock {
                        id: clock
                        color: ShellSettings.colors["inverse_surface"]
                    }
                }
            }
        }
    }
}
