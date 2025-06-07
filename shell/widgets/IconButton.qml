import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell.Widgets

StyledMouseArea {
    id: root

    property string source
    property var implicitSize: 24
    property var padding: 0
    property var radius: 20
    property color iconColor: "transparent"
    property bool colorizeIcon: iconColor != Qt.color("transparent")

    implicitWidth: implicitSize
    implicitHeight: implicitSize

    IconImage {
        id: iconImage
        source: root.source
        visible: !root.colorizeIcon

        anchors {
            fill: parent
            margins: root.padding
        }
    }

    IconImage {
        id: iconImageColorized
        source: root.source
        visible: false

        anchors {
            fill: parent
            margins: root.padding
        }
    }

    ColorOverlay {
        anchors.fill: iconImageColorized
        source: iconImageColorized
        color: root.iconColor
        visible: root.colorizeIcon
    }
}
