pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.widgets

Scope {
    id: root

    required property var bar

    property real gaps: 5

    property Item parentItem
    property PopupItem activeItem
    property PopupItem lastActiveItem

    property PopupItem shownItem: activeItem ?? lastActiveItem

    onActiveItemChanged: {
        if (activeItem != null) {
            activeItem.targetVisible = true;

            if (parentItem) {
                activeItem.parent = parentItem;
            }
        }

        if (lastActiveItem != null && lastActiveItem != activeItem) {
            lastActiveItem.targetVisible = false;
        }

        if (activeItem != null)
            lastActiveItem = activeItem;
    }

    function setItem(item: PopupItem) {
        activeItem = item;
    }

    function removeItem(item: PopupItem) {
        if (activeItem == item) {
            activeItem = null;
        }
    }

    function onHidden(item: PopupItem) {
        if (item == lastActiveItem) {
            lastActiveItem = null;
        }
    }

    LazyLoader {
        id: popupLoader
        activeAsync: root.shownItem != null

        PopupWindow {
            id: popup
            visible: true
            color: "transparent"
            implicitWidth: root.bar.width
            implicitHeight: Math.max(800, parentItem.targetHeight)

            anchor {
                window: root.bar
                rect: Qt.rect(0, 0, root.bar.width, root.bar.height)
                edges: Edges.Bottom | Edges.Left
                gravity: Edges.Bottom | Edges.Right
                adjustment: PopupAdjustment.None
            }

            mask: Region {
                item: parentItem
            }

            HyprlandFocusGrab {
                id: grab
                active: true
                windows: [popup, root.bar]
                onCleared: {
                    root.shownItem.closed();
                }
            }

            HyprlandWindow.visibleMask: Region {
                id: mask
                item: parentItem
            }

            StyledRectangle {
                id: parentItem
                width: Math.max(1, x2 - x1)
                height: Math.max(1, h)
                x: x1 ?? 0
                y: root.gaps
                clip: true

                readonly property var targetX: {
                    if (root.shownItem == null) {
                        return 0;
                    }

                    let owner = root.shownItem.owner;
                    let bar = root.bar;
                    let xPos = owner.mapToItem(bar.contentItem, 0, bar.height, owner.width, 0).x;

                    let rightEdge = xPos + targetWidth;
                    let maxRightEdge = popup.width;

                    if (rightEdge > maxRightEdge) {
                        // touching right edge, reposition
                        // console.log("touching right edge");
                        return maxRightEdge - targetWidth - root.gaps;
                    }

                    return xPos;
                }

                readonly property var targetWidth: root.shownItem?.implicitWidth ?? 0
                readonly property var targetHeight: root.shownItem?.implicitHeight ?? 0

                property var h
                property var x1
                property var x2

                property var largestAnimHeight: 0

                Component.onCompleted: {
                    root.parentItem = this;

                    if (root.activeItem) {
                        root.activeItem.parent = this;
                    }
                }

                SmoothedAnimation on x1 {
                    id: x1Anim
                    to: parentItem.targetX
                    onToChanged: {
                        velocity = (Math.max(parentItem.x1, to) - Math.min(parentItem.x1, to)) * 5;
                        restart();
                    }
                }

                SmoothedAnimation on x2 {
                    id: x2Anim
                    to: parentItem.targetX + parentItem.targetWidth
                    onToChanged: {
                        velocity = (Math.max(parentItem.x2, to) - Math.min(parentItem.x2, to)) * 5;
                        restart();
                    }
                }

                SmoothedAnimation on h {
                    id: heightAnim
                    to: parentItem.targetHeight
                    onToChanged: {
                        velocity = (Math.max(parentItem.height, to) - Math.min(parentItem.height, to)) * 5;
                        restart();
                    }
                }
            }
        }
    }
}
