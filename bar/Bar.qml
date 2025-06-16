import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "battery"
import "systray" as SysTray
import "popups" as Popup
import "mpris" as Mpris
import "../widgets" as Widgets
import ".."

PanelWindow {
    id: root
    color: ShellSettings.colors["surface"]
    implicitHeight: ShellSettings.settings.barHeight
    property alias popup: popupWindow

    anchors {
        top: true
        left: true
        right: true
    }

    // Popup window for all popups
    Popup.MenuWindow {
        id: popupWindow
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
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                spacing: 10
                anchors.fill: parent

                HyprWorkspaces {
                    screen: root.screen
                    Layout.fillHeight: true
                    Layout.leftMargin: 4
                }

                Widgets.Separator {
                    visible: activeWindow.visible
                    Layout.leftMargin: 5
                    Layout.rightMargin: 5
                }

                ActiveWindow {
                    id: activeWindow
                    Layout.preferredWidth: 400
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }

        // Center of bar
        WrapperItem {
            topMargin: 2
            bottomMargin: 2
            Layout.fillHeight: true

            Mpris.Button {
                bar: root
            }
        }

        // Right side of bar
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                anchors.fill: parent

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                SysTray.SysTray {
                    id: sysTray
                    popup: root.popup
                    Layout.fillHeight: true
                }

                BatteryIndicator {
                    id: batteryIndicator
                    popup: root.popup
                    Layout.fillHeight: true
                }

                Widgets.Separator {
                    Layout.leftMargin: 5
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
