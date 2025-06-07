import QtQuick
import qs

MouseArea {
    id: root
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    property real radius: 10
    property bool checked: false
    property var hoverColor: ShellSettings.colors.inactive.accent
    property var color: "transparent"

    Rectangle {
        color: root.containsMouse || root.checked ? root.hoverColor : root.color
        radius: root.radius
        anchors.fill: parent
    }
}
