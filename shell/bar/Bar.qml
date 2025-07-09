import QtQuick
import QtQuick.Layouts
import Quickshell
import "power"
import "volume"
import "systray" as SysTray
import "popups" as Popup
import "../widgets" as Widgets
import ".."

PanelWindow {
    id: root
    color: ShellSettings.colors["surface"]
    implicitHeight: ShellSettings.sizing.barHeight
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
        RowLayout {
            spacing: 5
            Layout.fillWidth: true
            Layout.fillHeight: true

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

        // Right side of bar
        RowLayout {
            spacing: 5
            Layout.fillWidth: true
            Layout.fillHeight: true

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            SysTray.SysTray {
                id: sysTray
                popup: root.popup
                Layout.fillHeight: true
            }

            VolumeIndicator {
                id: volumeIndicator
                popup: root.popup
                Layout.preferredWidth: this.height
                Layout.fillHeight: true
                Layout.topMargin: 2
                Layout.bottomMargin: 2
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
