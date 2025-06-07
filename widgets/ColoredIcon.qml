pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell.Widgets
import ".."

Item {
    id: root
    required property var source
    property var implicitSize: 0
    property var color: "white"
    readonly property real actualSize: Math.min(root.width, root.height)

    implicitWidth: implicitSize
    implicitHeight: implicitSize

    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: IconImage {
            implicitSize: root.actualSize
            source: root.source
        }
    }

    Rectangle {
        color: root.color
        anchors.fill: parent
    }
}
