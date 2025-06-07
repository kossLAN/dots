pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
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

    IconImage {
        anchors.fill: parent
        source: root.source
        layer.enabled: true
        layer.effect: MultiEffect {
            colorization: 1
            colorizationColor: root.color
        }
    }

    Rectangle {
        color: root.color
        anchors.fill: parent
    }
}
