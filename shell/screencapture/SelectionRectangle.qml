import QtQuick
import qs

Item {
    id: root
    width: 800
    height: 600

    property color overlayColor: "#80000000"
    property rect selectionRect: Qt.rect(0, 0, 0, 0)
    property point startPosition: Qt.point(0, 0)
    signal areaSelected(rect selection)
 
    // only send signal when selection rectangle has finished 
    onVisibleChanged: areaSelected(selectionRect)

    MouseArea {
        id: selectionArea
        anchors.fill: parent
        hoverEnabled: true

        onReleased: root.visible = false

        onPressed: mouse => {
            root.startPosition = Qt.point(mouse.x, mouse.y);
            rectangle.x = mouse.x;
            rectangle.y = mouse.y;
            rectangle.width = 0;
            rectangle.height = 0;
            root.selectionRect = Qt.rect(rectangle.x, rectangle.y, rectangle.width, rectangle.height);
        }

        onPositionChanged: mouse => {
            if (pressed) {
                rectangle.x = Math.min(root.startPosition.x, mouse.x);
                rectangle.y = Math.min(root.startPosition.y, mouse.y);
                rectangle.width = Math.abs(mouse.x - root.startPosition.x);
                rectangle.height = Math.abs(mouse.y - root.startPosition.y);

                root.selectionRect = Qt.rect(rectangle.x, rectangle.y, rectangle.width, rectangle.height);
            }
        }
    }

    Rectangle {
        id: overlayStart
        color: root.overlayColor
        visible: !selectionArea.containsPress
        anchors.fill: parent
    }

    Rectangle {
        id: overlayTop
        color: root.overlayColor
        x: 0
        y: 0
        width: parent.width
        height: Math.max(0, rectangle.y)
        visible: selectionArea.containsPress
    }

    Rectangle {
        id: overlayLeft
        color: root.overlayColor
        x: 0
        y: rectangle.y
        width: Math.max(0, rectangle.x)
        height: Math.max(0, rectangle.height)
        visible: selectionArea.containsPress
    }

    Rectangle {
        id: overlayRight
        color: root.overlayColor
        x: rectangle.x + rectangle.width
        y: rectangle.y
        width: Math.max(0, parent.width - (rectangle.x + rectangle.width))
        height: Math.max(0, rectangle.height)
        visible: selectionArea.containsPress
    }

    Rectangle {
        id: overlayBottom
        color: root.overlayColor
        x: 0
        y: rectangle.y + rectangle.height
        width: parent.width
        height: Math.max(0, parent.height - (rectangle.y + rectangle.height))
        visible: selectionArea.containsPress
    }

    // The visible selection rectangle with border drawn above overlays
    Rectangle {
        id: rectangle
        color: "transparent"
        radius: 8
        border.color: ShellSettings.colors.active_translucent
        border.width: 2
        x: 0
        y: 0
        width: 0
        height: 0
        z: 1
        visible: selectionArea.containsPress
    }
}
