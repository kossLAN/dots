import QtQuick
import Quickshell.Widgets
import ".."

Item {
    id: root
    property string source
    property var implicitSize: 24 // Default size if not specified
    property var padding: 0
    property var radius: 5
    signal clicked

    implicitWidth: implicitSize
    implicitHeight: implicitSize

    Rectangle {
        id: iconBackground
        color: ShellGlobals.colors.accent
        radius: root.radius
        visible: iconButton.containsMouse
        anchors.fill: parent
    }

    IconImage {
        id: iconImage
        source: root.source

        anchors {
            fill: parent
            margins: root.padding
        }
    }

    MouseArea {
        id: iconButton
        hoverEnabled: true
        anchors.fill: parent
        onPressed: root.clicked()
    }
}
