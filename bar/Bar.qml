import QtQuick
import QtQuick.Layouts
import Quickshell
import "control" as Control
import "systray" as SysTray
import "notifications" as Notifications
import "popups" as Popup
import "../widgets" as Widgets
import ".."

PanelWindow {
    id: root
    color: ShellSettings.settings.colors["surface"]
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
        spacing: 15

        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
            leftMargin: 4
        }

        HyprWorkspaces {
            Layout.fillWidth: false
            Layout.preferredHeight: parent.height
            Layout.margins: 4
        }

        Widgets.Separator {
            visible: activeWindow.visible
        }

        ActiveWindow {
            id: activeWindow
            Layout.preferredWidth: 400
        }
    }

    // Right
    RowLayout {
        spacing: 15

        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            rightMargin: 10
        }

        SysTray.SysTray {
            id: sysTray
            popup: root.popup
        }

        // Notifications.NotificationButton {
        //     implicitSize: 16
        //     bar: root
        // }

        BatteryIndicator {
            id: batteryIndicator
        }

        // Control.Button {
        //     bar: root
        //     screen: root
        // }

        Widgets.Separator {}

        Clock {
            id: clock
            color: ShellSettings.settings.colors["inverse_surface"]
        }
    }
}
