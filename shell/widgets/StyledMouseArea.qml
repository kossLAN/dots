import QtQuick
import qs

MouseArea {
    id: root
    hoverEnabled: true

    property real radius: width / 2
    property bool checked: false
    property var activeColor: ShellSettings.colors.active_translucent
    property var inactiveColor: "transparent"

    Rectangle {
        color: root.containsMouse || root.checked ? root.activeColor : root.inactiveColor 
        radius: root.radius
        anchors.fill: parent

        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }
    }
}
