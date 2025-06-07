import QtQuick
import QtQuick.Layouts
import Quickshell.I3
import ".."

RowLayout {
    property var sortedWorkspaces: {
        let values = I3.workspaces.values.slice();
        values.sort(function (a, b) {
            if (!a?.num)
                return 1;
            if (!b?.num)
                return -1;

            return a.num - b.num;
        });

        return values;
    }

    spacing: 6
    visible: I3.monitors.values.length != 0

    Repeater {
        model: parent.sortedWorkspaces

        Rectangle {
            required property var modelData
            width: 25
            height: 12
            radius: 10

            color: getColor(modelData, workspaceButton.containsMouse)

            MouseArea {
                id: workspaceButton
                anchors.fill: parent
                hoverEnabled: true
                onPressed: I3.dispatch(`workspace number ${parent.modelData.num}`)
            }
        }
    }

    function getColor(modelData, isHovered) {
        if (!modelData?.id || !I3.focusedMonitor?.focusedWorkspace?.num)
            return ShellGlobals.colors.light;

        if (isHovered)
            return ShellGlobals.colors.midlight;

        if (I3.focusedMonitor.focusedWorkspace.num == modelData.num)
            return ShellGlobals.colors.accent;

        return ShellGlobals.colors.light;
    }
}
