pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.widgets
import qs.notifications

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

            // Notification Center is not part of the popup system
            if (NotificationCenter.notificationsOpen) {
                NotificationCenter.api.close();
            }
        }

        if (lastActiveItem != null && lastActiveItem != activeItem) {
            lastActiveItem.targetVisible = false;
        }

        if (activeItem != null) {
            lastActiveItem = activeItem;
        }
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

    property real scaleMul: lastActiveItem && lastActiveItem.targetVisible ? 1 : 0

    Behavior on scaleMul {
        SmoothedAnimation {
            velocity: 5
        }
    }

    LazyLoader {
        id: popupLoader
        active: root.shownItem != null

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
                    if (!active) {
                        root.shownItem.closed();
                    }
                }
            }

            // HyprlandWindow.opacity: root.scaleMul

            HyprlandWindow.visibleMask: popup.mask

            Connections {
                target: root

                function onScaleMulChanged() {
                    popup.mask.changed();
                }
            }

            StyledRectangle {
                id: parentItem
                width: targetWidth
                height: targetHeight
                x: targetX
                y: root.gaps

                transform: Scale {
                    origin.x: parentItem.targetX
                    origin.y: 0
                    xScale: 1
                    yScale: root.scaleMul
                }

                readonly property var targetWidth: root.shownItem?.implicitWidth ?? 0
                readonly property var targetHeight: root.shownItem?.implicitHeight ?? 0

                readonly property var targetX: {
                    if (root.shownItem == null) {
                        return 0;
                    }

                    let owner = root.shownItem.owner;
                    let bar = root.bar;
                    let isCentered = root.shownItem.centered;
                    let xPos = owner.mapToItem(bar.contentItem, 0, bar.height, owner.width, 0).x;

                    let rightEdge = xPos + targetWidth;
                    let maxRightEdge = popup.width;

                    if (isCentered) {
                        return xPos - (targetWidth / 2) + (owner.width / 2);
                    }

                    if (rightEdge > maxRightEdge) {
                        // touching right edge, reposition
                        // console.log("touching right edge");
                        return maxRightEdge - targetWidth - root.gaps;
                    }

                    return xPos;
                }

                Component.onCompleted: {
                    root.parentItem = this;

                    if (root.activeItem) {
                        root.activeItem.parent = this;
                    }
                }

                Behavior on x {
                    enabled: root.lastActiveItem != null && root.shownItem.animate

                    SmoothedAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }

                Behavior on width {
                    enabled: root.lastActiveItem != null && root.shownItem.animate

                    SmoothedAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }

                Behavior on height {
                    enabled: root.lastActiveItem != null && root.shownItem.animate

                    SmoothedAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }

                // SmoothedAnimation on height {
                //     duration: 200
                //     easing.type: Easing.InOutQuad
                //     to: parentItem.targetHeight
                //     onToChanged: restart()
                // }
            }
        }
    }
}
