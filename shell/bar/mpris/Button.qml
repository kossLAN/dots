import QtQuick
import "../../mpris" as Mpris
import "../../widgets" as Widgets
import "../.."

Widgets.MaterialButton {
    id: root
    radius: 6
    implicitWidth: mediaInfo.contentWidth + 8
    implicitHeight: parent.height
    // onClicked: {
    //     popup.visible = !popup.visible;
    // }

    required property var bar
    property var player: Mpris.Controller.trackedPlayer

    Text {
        id: mediaInfo
        text: root.player?.trackTitle ?? ""
        color: root.containsMouse ? ShellSettings.colors["inverse_primary"] : ShellSettings.colors["inverse_surface"]
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pointSize: 11
        anchors.centerIn: parent

        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }
    }
}

// WidgetWindow {
//     id: popup
//     visible: false
//     parentWindow: root.bar
//
//     // anchor.window: root.bar
// }
