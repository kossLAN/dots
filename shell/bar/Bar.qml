import QtQuick
import QtQuick.Layouts
import Quickshell
import "power"
// import "volume"
import "systray" as SysTray
import "popups" as Popup
import "../widgets" as Widgets
import ".."

PanelWindow {
    id: root
    color: "transparent" 
    implicitHeight: ShellSettings.sizing.barHeight
    property alias popup: popupWindow

    anchors {
        top: true
        left: true
        right: true
    }

    Rectangle {
        color: ShellSettings.colors.surface 
        opacity: 0.15 
        anchors.fill: parent
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
            spacing: 15
            Layout.fillWidth: true
            Layout.fillHeight: true

            // HyprWorkspaces {
            //     screen: root.screen
            //     Layout.fillHeight: true
            // }

            // ActiveWindow {
            //     id: activeWindow
            //     Layout.preferredWidth: 400
            // }
        }

        // Right side of bar
        RowLayout {
            spacing: 10
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignRight

            SysTray.SysTray {
                id: sysTray
                // popup: root.popup
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
            //     popup: root.popup
            //     Layout.fillHeight: true
            // }

            // Widgets.Separator {
            //     Layout.leftMargin: 5
            //     Layout.rightMargin: 5
            // }

            Clock {
                id: clock
                color: ShellSettings.colors["active"]
            }
        }
    }
}
