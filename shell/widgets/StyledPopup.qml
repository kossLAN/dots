import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import qs

PopupWindow {
    id: root
    color: "transparent"
    implicitWidth: container.width
    implicitHeight: container.height

    default property alias contentItem: container.children

    function open() {
        // root.anchor.rect.y = -root.implicitHeight;
        root.visible = true;
        grab.active = true;
        // slideAnimation.start();
    }

    function hide() {
        root.visible = false;
        grab.active = false;
    }

    // PropertyAnimation {
    //     id: slideAnimation
    //     target: root.anchor.rect
    //     property: "y"
    //     from: -root.implicitHeight  // Off-screen position
    //     to: 0  // On-screen position
    //     duration: 300  // Animation duration in milliseconds
    // }

    HyprlandFocusGrab {
        id: grab
        windows: [root]
        onCleared: root.hide()
    }

    WrapperRectangle {
        id: container
        margin: 5
        radius: 12
        color: ShellSettings.colors.active.window

        border {
            width: 1
            color: ShellSettings.colors.active.mid
        }
    }
}
