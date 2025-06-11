import QtQuick
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import ".."

Item {
    id: root
    property string source
    property var implicitSize: 24
    property var padding: 0
    property var radius: 20
    property var activeRectangle: true
    property var color: ShellSettings.colors["inverse_surface"]
    property var activeColor: ShellSettings.colors["inverse_primary"]
    signal clicked

    implicitWidth: implicitSize
    implicitHeight: implicitSize

    Rectangle {
        id: iconBackground
        color: ShellSettings.colors["primary"]
        radius: root.radius
        visible: iconButton.containsMouse && root.activeRectangle
        anchors.fill: parent
    }

    // Figure out a way to color images better 
    IconImage {
        id: iconImage
        source: root.source
        visible: true 
        // color: {
        //     if (!activeRectangle)
        //         return root.color;
        //
        //     return iconButton.containsMouse ? root.activeColor : root.color;
        // }

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
