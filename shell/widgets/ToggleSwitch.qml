import QtQuick
import qs

MouseArea {
    id: root

    property bool checked: false
    property var accentColor: ShellSettings.colors.active.accent
    property var trackColor: ShellSettings.colors.active.alternateBase
    property var handleColor: ShellSettings.colors.active.windowText
    property real trackWidth: 36
    property real trackHeight: 18
    property real handleSize: 14
    property real handleMargin: 2

    implicitWidth: trackWidth
    implicitHeight: trackHeight
    hoverEnabled: true

    onClicked: checked = !checked

    Rectangle {
        id: track
        anchors.centerIn: parent
        width: root.trackWidth
        height: root.trackHeight
        radius: height / 2
        color: root.checked ? root.accentColor : root.trackColor

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        Rectangle {
            id: handle
            width: root.handleSize
            height: root.handleSize
            radius: width / 2
            color: root.containsMouse || root.pressed ? 
                   Qt.lighter(root.handleColor, 1.3) : 
                   root.handleColor
            anchors.verticalCenter: parent.verticalCenter
            x: root.checked ? 
               (track.width - width - root.handleMargin) : 
               root.handleMargin

            Behavior on x {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 100
                }
            }
        }
    }
}
