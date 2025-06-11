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

            radius: height / 2
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: 12
            Layout.preferredWidth: {
                if (Hyprland.focusedMonitor.activeWorkspace.id == modelData.id)
                    return 25;

                return 12;
            }

            color: {
                let value = Qt.color(ShellSettings.colors["secondary"]).darker(2);

                if (!modelData?.id || !Hyprland.focusedMonitor?.activeWorkspace?.id)
                    return value;

                if (workspaceButton.containsMouse) {
                    value = ShellSettings.colors["on_primary"];
                } else if (Hyprland.focusedMonitor.activeWorkspace.id == modelData.id) {
                    value = ShellSettings.colors["primary"];
                }

                return value;
            }

            Behavior on Layout.preferredWidth {
                SmoothedAnimation {
                    duration: 150
                    velocity: 200
                    easing.type: Easing.OutCubic
                }
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
