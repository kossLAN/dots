import QtQuick
import qs

Rectangle {
    id: root
    property bool checked: false
    implicitHeight: 12
    implicitWidth: 12
    radius: width / 2
    color: checked ? ShellSettings.colors.active.highlight : ShellSettings.colors.active.mid

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    Rectangle {
        anchors.centerIn: parent
        visible: root.checked
        width: parent.width * 0.5
        height: width
        radius: width / 2
        color: ShellSettings.colors.active.highlightedText
    }
}
