import QtQuick
import ".."

MouseArea {
    id: root
    hoverEnabled: true

    property real radius: width / 2
    property bool checked: false
    property var activeColor: ShellSettings.colors["primary"]
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
