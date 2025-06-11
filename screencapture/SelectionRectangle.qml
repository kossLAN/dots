import QtQuick
import ".."

Canvas {
    id: root

    property color overlayColor: "#80000000"
    property color outlineColor: ShellSettings.colors["primary"]
    property rect selectionRect
    property point startPosition
    signal areaSelected(rect selection)

    onPaint: {
        var ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);

        // grey overlay
        ctx.fillStyle = overlayColor;
        ctx.fillRect(0, 0, width, height);

        // cut out the selection rectangle
        ctx.globalCompositeOperation = "destination-out";
        ctx.fillRect(selectionRect.x, selectionRect.y, selectionRect.width, selectionRect.height);
        ctx.globalCompositeOperation = "source-over";
        ctx.strokeStyle = outlineColor; 
        ctx.lineWidth = 2; 
        ctx.strokeRect(selectionRect.x, selectionRect.y, selectionRect.width, selectionRect.height);
    }

    MouseArea {
        anchors.fill: parent

        onPressed: mouse => {
            root.startPosition = Qt.point(mouse.x, mouse.y);
        }

        onPositionChanged: mouse => {
            if (pressed) {
                var x = Math.min(root.startPosition.x, mouse.x);
                var y = Math.min(root.startPosition.y, mouse.y);
                var width = Math.abs(mouse.x - root.startPosition.x);
                var height = Math.abs(mouse.y - root.startPosition.y);

                root.selectionRect = Qt.rect(x, y, width, height);
                root.requestPaint();
            }
        }

        onReleased: mouse => {
            root.visible = false;
            root.areaSelected(root.selectionRect);
        }
    }
}
