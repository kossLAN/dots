import QtQuick
import qs

MouseArea {
    id: root
    hoverEnabled: true

    property real radius: 10  
    property bool checked: false
    property var activeColor: ShellSettings.colors.active_translucent
    property var inactiveColor: "transparent"

    Rectangle {
        color: root.containsMouse || root.checked ? root.activeColor : root.inactiveColor
        radius: root.radius
        anchors.fill: parent

        border {
            width: root.containsMouse ? 1 : 0
            color: ShellSettings.colors.active_translucent
        }

        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }
    }
}
