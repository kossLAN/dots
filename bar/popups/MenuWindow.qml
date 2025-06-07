import Quickshell
import Quickshell.Widgets
import QtQuick
import "../.."

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

    function set(item, content) {
        content.visible = true;

        let itemPos = item.mapToItem(bar.contentItem, 0, bar.height, item.width, 0).x;
        // let contentWidth = content.width;

        popupContainer.x = itemPos;
        popupContent.data = content;

        // popupContent.opacity = 0;
        // popupContainer.opacity = 0;
        popupContainer.opacity = 1;
        popupContent.opacity = 1;
        root.visible = true;
    }

    // function set(item, content) {
    //     content.visible = true;
    //
    //     let itemPos = item.mapToItem(bar.contentItem, 0, bar.height, item.width, 0).x;
    //     let contentWidth = content.width;
    //     let padding = 5;
    //     let xPos = itemPos;
    //     let idealX = xPos;
    //     let idealRightEdge = idealX + contentWidth;
    //
    //     // check if touching right edge
    //     let maxRightEdge = root.width - padding;
    //     let isTouchingRightEdge = idealRightEdge > maxRightEdge;
    //
    //     if (isTouchingRightEdge) {
    //         // touching right edge
    //         let constrainedX = maxRightEdge - contentWidth;
    //         constrainedX = Math.max(0, constrainedX);
    //
    //         popupContainer.x = constrainedX;
    //         popupContainer.implicitWidth = 0;
    //         popupContent.data = content;
    //         // popupContent.implicitWidth = contentWidth;
    //     } else {
    //         // not touching any edge
    //         // popupContent.implicitWidth = contentWidth;
    //         popupContainer.x = idealX;
    //         popupContent.data = content;
    //     }
    //
    //     popupContainer.y = padding;
    //
    //     popupContent.opacity = 0;
    //     popupContainer.opacity = 0;
    //     popupContainer.opacity = 1;
    //     popupContent.opacity = 1;
    //     root.visible = true;
    // }

    function clear() {
        popupContainer.opacity = 0;
        popupContent.opacity = 0;
        popupContent.data = [];
    }

    WrapperRectangle {
        id: popupContainer
        property real targetX: 0

        color: ShellSettings.settings.colors["surface"]
        radius: 12
        margin: 8
        clip: true
        opacity: 0
        visible: opacity > 0

        onVisibleChanged: {
            if (!visible) {
                root.visible = false;
            }
        }

        Item {
            id: popupContent
            implicitWidth: Math.max(childrenRect.width, 120)
            implicitHeight: Math.max(childrenRect.height, 60)
            opacity: 1

            // Behavior on opacity {
            //     NumberAnimation {
            //         id: contentOpacity
            //         duration: 350
            //         easing.type: Easing.Linear
            //         from: 0
            //         to: 1
            //     }
            // }
        }

        HoverHandler {
            id: hover
            enabled: true
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onHoveredChanged: {
                if (hovered == false)
                    root.clear();
            }
        }

        // Behavior on opacity {
        //     NumberAnimation {
        //         duration: 500
        //         easing.type: Easing.InOutQuad
        //     }
        // }
        //
        // Behavior on x {
        //     enabled: root.visible
        //     SmoothedAnimation {
        //         duration: 300
        //         easing.type: Easing.OutQuad
        //     }
        // }
        //
        // Behavior on implicitWidth {
        //     enabled: root.visible
        //     SmoothedAnimation {
        //         duration: 300
        //         easing.type: Easing.OutQuad
        //     }
        // }
        //
        // Behavior on implicitHeight {
        //     SmoothedAnimation {
        //         duration: 200
        //         easing.type: Easing.Linear
        //     }
        // }
    }
}
