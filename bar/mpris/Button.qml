import Quickshell.Widgets
import QtQuick
import "../../mpris" as Mpris
import "../.."

WrapperRectangle {
    id: root
    color: button.containsMouse ? ShellSettings.colors["primary"] : "transparent"
    radius: 6
    leftMargin: 5
    rightMargin: 5

    required property var bar
    property var player: Mpris.Controller.trackedPlayer

    Text {
        id: mediaInfo
        text: root.player?.trackTitle ?? ""
        color: button.containsMouse ? ShellSettings.colors["inverse_primary"] : ShellSettings.colors["inverse_surface"]
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pointSize: 11
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
            id: button
            anchors.fill: parent
            hoverEnabled: true

            onClicked: {
                popup.visible = !popup.visible;
            }
        }

        WidgetWindow {
            id: popup
            visible: false
            parentWindow: root.bar

            // anchor.window: root.bar
        }

        // Item {
        //     id: menu
        //     visible: false
        //     implicitWidth: 250
        //     implicitHeight: 80
        // }

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: 100
        }
    }
}
