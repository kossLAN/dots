pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import QtQuick
import qs

PopupWindow {
    id: root
    visible: false
    color: "transparent"
    implicitWidth: bar.width
    implicitHeight: Math.max(1000, bar.height)
    mask: Region {
        item: surface
    }

    anchor {
        window: bar
        rect: Qt.rect(0, 0, bar.width, bar.height)
        edges: Edges.Bottom | Edges.Left
        gravity: Edges.Bottom | Edges.Right
        adjustment: PopupAdjustment.None
    }

    required property var bar
    property var currentMenu
    property real padding: 5

    function set(item) {

        // Clear surface
        if (content.children.includes(item.menu)) {
            console.log("Clearing popup surface.");
            root.currentMenu = undefined;
            content.children = [];
            // surface.implicitHeight = 0;
            surface.opacity = 0;
            contentOpacity.restart();
            grab.active = false;
            return;
        }

        // Set surface
        console.log("Setting popup surface.");
        root.visible = true;
        root.currentMenu = item.menu
        content.children = [item.menu];
        // content.implicitWidth = item.menu.implicitWidth;
        // content.implicitHeight = item.menu.implicitHeight;

        let itemPos = item.mapToItem(root.bar.contentItem, 0, root.bar.height, item.width, 0).x;

        // Check right edge
        let rightEdge = itemPos + surface.implicitWidth;
        let maxRightEdge = root.width - padding;
        let isTouchingRightEdge = rightEdge > maxRightEdge;

        if (isTouchingRightEdge) {
            // touching right edge, reposition
            surface.x = maxRightEdge - surface.implicitWidth;
            surface.y = padding;
        } else {
            // not touching right edge
            surface.x = itemPos;
            surface.y = padding;
        }

        surface.opacity = 1;
        contentOpacity.restart();
        grab.active = true;
    }

    HyprlandFocusGrab {
        id: grab
        windows: [root, root.bar]
        onCleared: {
            surface.opacity = 0;
            contentOpacity.restart();
            root.currentMenu = undefined;
            content.children = [];
        }
    }

    WrapperRectangle {
        id: surface
        opacity: 0
        visible: opacity > 0
        color: ShellSettings.colors.surface_translucent
        clip: true
        margin: 5
        radius: 12

        border {
            width: 1
            color: ShellSettings.colors.active_translucent
        }

        // Animating implicit widht/height causes issues, this works but
        // is kind of cursed, but fuck it. Better solutions welcome.
        width: implicitWidth
        height: implicitHeight

        Item {
            id: content
            implicitWidth: Math.max(root.currentMenu?.width, 60) 
            implicitHeight: root.currentMenu?.height ?? 0

            NumberAnimation {
                id: contentOpacity
                target: content
                property: "opacity"
                from: 0
                to: 1
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on width {
            enabled: root.visible 
            SmoothedAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on height {
            SmoothedAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on x {
            enabled: root.visible 
            SmoothedAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
    }
}
