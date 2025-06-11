import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import ".."

RowLayout {
    spacing: 6
    visible: Hyprland.monitors.values.length != 0

    required property var screen 

    Repeater {
        model: ScriptModel {
            values: Hyprland.workspaces.values.slice().filter(
                workspace => workspace.monitor === Hyprland.monitorFor(screen)
            ).sort((a,b) => {
                return a.id - b.id;
            });
        }

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
