import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import qs

PopupWindow {
    id: root
    color: "transparent"
    implicitWidth: bar.width
    implicitHeight: Math.max(popupContainer.height, 800) + 20

    mask: Region {
        item: popupContainer
    }

    anchor {
        window: bar
        rect: Qt.rect(0, 0, bar.width, bar.height)
        edges: Edges.Bottom | Edges.Left
        gravity: Edges.Bottom | Edges.Right
        adjustment: PopupAdjustment.None
    }

    required property var bar
    property var isOpen: false
    property var padding: 5
    property var item
    property var content

    function set(item, content) {
        root.item = item;
        root.content = content;
        popupContent.data = content;

        let itemPos = item.mapToItem(root.bar.contentItem, 0, root.bar.height, item.width, 0).x;
        position(itemPos);

        popupContainer.visible = false;
    }

    function position(itemPos) {
        if (itemPos === undefined)
            return;

        let rightEdge = itemPos + popupContainer.implicitWidth;
        let maxRightEdge = root.width - padding;
        let isTouchingRightEdge = rightEdge > maxRightEdge;

        if (isTouchingRightEdge) {
            // touching right edge, reposition
            // console.log("touching right edge");
            popupContainer.x = maxRightEdge - popupContainer.implicitWidth;
            popupContainer.y = padding;
        } else {
            // not touching right edge
            popupContainer.x = itemPos;
            popupContainer.y = padding;
        }
    }

    function show() {
        grab.active = true;
        isOpen = true;
        root.visible = true; // set and leave open
        root.content.visible = true;
        popupContainer.visible = true;
    }

    function hide() {
        grab.active = false;
        isOpen = false;
        popupContainer.visible = false;

        root.item = undefined;
        root.content = undefined;
        popupContent.data = [];
    }

    function toggle() {
        if (isOpen) {
            hide();
        } else {
            show();
        }
    }

    Rectangle {
        color: ShellSettings.colors.surface_translucent
        opacity: 0.15
        radius: 12
        anchors.fill: popupContainer
        border.color: ShellSettings.colors.active
    }

    WrapperItem {
        id: popupContainer
        margin: 8
        clip: true
        x: root.bar.width
        onVisibleChanged: root.visible = visible

        // needed to handle occurences where items are resized while open
        onImplicitWidthChanged: {
            if (root.isOpen && popupContent.data !== []) {
                // console.log("repositioning popup");
                let itemPos = root.item.mapToItem(root.bar.contentItem, 0, root.bar.height, root.item.width, 0).x;
                root.position(itemPos);
            }
        }

        Item {
            id: popupContent
            implicitWidth: Math.max(root.content?.width, 60)
            implicitHeight: Math.max(childrenRect.height, 60)
        }

        HyprlandFocusGrab {
            id: grab
            windows: [root, root.bar]
            onCleared: {
                root.hide();
            }
        }
    }
}
