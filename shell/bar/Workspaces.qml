import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs

RowLayout {
    spacing: 6
    visible: Hyprland.monitors.values.length != 0

    required property var screen

    Repeater {
        id: workspaceButtons

        model: ScriptModel {
            values: Hyprland.workspaces.values.slice().filter(workspace => workspace.monitor === Hyprland.monitorFor(screen))
        }

        Rectangle {
            radius: height / 2

            color: {
                let value = ShellSettings.colors.active_translucent;

                if (!modelData?.id || !Hyprland.focusedMonitor?.activeWorkspace?.id)
                    return value;

                if (workspaceButton.containsMouse) {
                    value = ShellSettings.colors.highlight;
                } else if (Hyprland.focusedMonitor.activeWorkspace.id === modelData.id) {
                    value = ShellSettings.colors.highlight;
                }

                return value;
            }

            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: 12
            Layout.preferredWidth: {
                if (Hyprland.focusedMonitor?.activeWorkspace?.id === modelData?.id)
                    return 25;

                return 12;
            }

            required property var modelData

            Behavior on Layout.preferredWidth {
                SmoothedAnimation {
                    duration: 150
                    velocity: 200
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 100
                    easing.type: Easing.OutQuad
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
