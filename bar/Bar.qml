import QtQuick
import QtQuick.Layouts
import Quickshell
import "battery"
import "control" as Control
import "systray" as SysTray
import "notifications" as Notifications
import "popups" as Popup
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

    // Left
    RowLayout {
        spacing: 10

        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
            leftMargin: 4
        }

        HyprWorkspaces {
            screen: root.screen
            Layout.fillWidth: false
            Layout.preferredHeight: parent.height
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
    }

    // Right
    RowLayout {
        spacing: 10

        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            rightMargin: 4
        }

        SysTray.SysTray {
            id: sysTray
            popup: root.popup
        }

        // Notifications.NotificationButton {
        //     implicitSize: 16
        //     bar: root
        // }

        // Text {
        //     text: "home"
        //     color: "white"
        //     font.family: "Material Symbols Rounded"
        //     renderType: Text.NativeRendering
        //     textFormat: Text.PlainText
        //     font.pointSize: 14
        //
        //     font.variableAxes: {
        //         "FILL": 0
        //     }
        // }

        BatteryIndicator {
            id: batteryIndicator
            popup: root.popup
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
