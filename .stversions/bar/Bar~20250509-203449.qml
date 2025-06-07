import QtQuick
import QtQuick.Layouts
import Quickshell
import "mpris" as Mpris
import "volume" as Volume
import "../widgets" as Widgets
import ".."

PanelWindow {
    id: root
    color: ShellGlobals.colors.base
    height: 25

    anchors {
        top: true
        left: true
        right: true
    }

    /// Widgets - Everything here is sorted where it appears on the bar.

    // Left
    RowLayout {
        spacing: 15

        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
            leftMargin: 10
        }

        // Whatever is available will display
        HyprWorkspaces {}
        SwayWorkspaces {}

        Widgets.Separator {
            visible: activeWindow.visible
        }

        ActiveWindow {
            id: activeWindow
            Layout.preferredWidth: 250
        }
    }

    // Middle
    Mpris.Status {
        id: mprisStatus
        bar: root
        anchors.centerIn: parent
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

        SysTray {
            id: sysTray
            bar: root
        }

        Widgets.Separator {
            visible: sysTray.visible
        }

        RowLayout {
            spacing: 5

            BatteryIndicator {
                id: batteryIndicator
            }

            Volume.Button {
                bar: root
            }
        }

        Widgets.Separator {}

        Clock {
            id: clock
            color: ShellGlobals.colors.text
        }
    }
}
