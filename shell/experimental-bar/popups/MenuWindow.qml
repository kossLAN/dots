import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import QtQuick.Shapes
// import QtQuick.Effects
import "../.."

// In need of heavy refactor
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
    property var padding: ShellSettings.sizing.borderWidth
    property var radius: 12
    property var item
    property var content

    function set(item, content) {
        root.item = item;
        root.content = content;
        popupContent.data = content;

        let itemPos = item.mapToItem(root.bar.contentItem, 0, root.bar.height, item.width, 0).x;
        position(itemPos);

        popupContainer.opacity = 0;
        popupContent.opacity = 0;
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
            popupContainer.y = 0;
            popupContainer.bottomLeftRadius = radius;
            popupContainer.bottomRightRadius = 0;
        } else {
            // not touching right edge
            popupContainer.x = itemPos;
            popupContainer.y = 0;
            popupContainer.bottomLeftRadius = radius;
            popupContainer.bottomRightRadius = radius;
        }
    }

    function show() {
        grab.active = true;
        isOpen = true;
        root.visible = true; // set and leave open
        root.content.visible = true;
        popupContainer.opacity = 1;
        popupContent.opacity = 1;
    }

    function hide() {
        grab.active = false;
        isOpen = false;
        popupContainer.opacity = 0;
        popupContent.opacity = 0;

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

    // RectangularShadow {
    //     radius: popupContainer.radius
    //     anchors.fill: popupContainer
    //     opacity: popupContainer.opacity
    //     visible: popupContainer.visible
    //     blur: 10
    //     spread: 2
    // }

    Shape {
        id: shapeContainer 
        // anchors.fill: popupContainer
        width: implicitWidth
        height: implicitHeight
        opacity: popupContainer.opacity
        

        WrapperRectangle {
            id: popupContainer
            color: ShellSettings.colors["surface"]
            margin: 8
            clip: true
            opacity: 0
            // visible: opacity > 0
            // x: root.bar.width

            // spooky, likely to cause problems lol
            width: implicitWidth
            height: implicitHeight

            onVisibleChanged: root.visible = visible

            // needed to handle occurrences where items are resized while open
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

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.Linear
                        from: 0
                        to: 1
                    }
                }
            }

            HyprlandFocusGrab {
                id: grab
                windows: [root, root.bar]
                onCleared: {
                    root.hide();
                }
            }

            Behavior on width {
                enabled: root.isOpen
                SmoothedAnimation {
                    duration: 200
                    easing.type: Easing.Linear
                }
            }

            Behavior on height {
                SmoothedAnimation {
                    duration: 200
                    easing.type: Easing.Linear
                }
            }

            Behavior on x {
                enabled: root.isOpen
                SmoothedAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }
        }

        ShapePath {
            strokeWidth: -1
            fillColor: ShellSettings.colors["surface"]
            startX: popupContainer.x - 25
            startY: popupContainer.y

            PathLine {
                relativeX: 25
                relativeY: 0
            }

            PathLine {
                relativeX: 0
                relativeY: 25
            }

            PathArc {
                direction: PathArc.Counterclockwise
                relativeX: -25
                relativeY: -25
                radiusX: 25
                radiusY: 25
                useLargeArc: false
            }

            // PathLine {
            //     x: 0
            //     y: 12
            // } // Vertical line down
            // PathLine {
            //     x: 12
            //     y: 12
            // } // Horizontal line to the right
            // PathLine {
            //     x: 12
            //     y: 0
            // } // Horizontal line back to the top
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.Linear
            }
        }
    }
}
