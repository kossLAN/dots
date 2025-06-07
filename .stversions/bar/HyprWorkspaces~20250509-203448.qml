import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import ".."

RowLayout {
    property var sortedWorkspaces: {
        let values = Hyprland.workspaces.values.slice();
        values.sort(function (a, b) {
            return a.id - b.id;
        });

        return values;
    }

    spacing: 6
    visible: Hyprland.monitors.values.length != 0

    Repeater {
        model: parent.sortedWorkspaces

        Rectangle {
            required property var modelData
            width: 25
            height: 12
            radius: 10

            color: {
                let value = ShellGlobals.colors.light;

                if (!modelData?.id || !Hyprland.focusedMonitor?.activeWorkspace?.id)
                    return value;

                if (workspaceButton.containsMouse) {
                    value = ShellGlobals.colors.midlight;
                } else if (Hyprland.focusedMonitor.activeWorkspace.id == modelData.id) {
                    value = ShellGlobals.colors.accent;
                }

                return value;
            }

            MouseArea {
                id: workspaceButton
                anchors.fill: parent
                hoverEnabled: true
                onPressed: Hyprland.dispatch(`workspace ${parent.modelData.id}`)
            }
        }
    }
}
