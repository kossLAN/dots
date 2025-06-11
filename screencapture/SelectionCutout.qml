import QtQuick
import ".."

Canvas {
    id: root
    anchors.fill: parent

    property color overlayColor: "#80000000"
    property color borderColor: ShellSettings.colors["primary"]
    property real borderWidth: 3
    property real handleSize: 16
    property var screen

    property real centerX: width / 2
    property real centerY: height / 2
    property real minWidth: 400
    property real minHeight: 300

    // rect that holds positional data for the selection 
    property rect selectionRect: Qt.rect(centerX - minWidth / 2, centerY - minHeight / 2, minWidth, minHeight)

    // handle positions 
    property point topLeftHandle: Qt.point(selectionRect.x, selectionRect.y)
    property point topRightHandle: Qt.point(selectionRect.x + selectionRect.width, selectionRect.y)
    property point bottomLeftHandle: Qt.point(selectionRect.x, selectionRect.y + selectionRect.height)
    property point bottomRightHandle: Qt.point(selectionRect.x + selectionRect.width, selectionRect.y + selectionRect.height)

    // dragging state
    property int activeHandle: -1
    property point dragStart: Qt.point(0, 0)
    property rect initialRect: Qt.rect(0, 0, 0, 0)

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

        // draw border
        ctx.strokeStyle = borderColor;
        ctx.lineWidth = borderWidth;
        ctx.beginPath();
        ctx.moveTo(topLeftHandle.x, topLeftHandle.y);
        ctx.lineTo(topRightHandle.x, topRightHandle.y);
        ctx.lineTo(bottomRightHandle.x, bottomRightHandle.y);
        ctx.lineTo(bottomLeftHandle.x, bottomLeftHandle.y);
        ctx.closePath();
        ctx.stroke();

        // draw handles
        ctx.fillStyle = borderColor;
        drawHandle(ctx, topLeftHandle);
        drawHandle(ctx, topRightHandle);
        drawHandle(ctx, bottomLeftHandle);
        drawHandle(ctx, bottomRightHandle);
    }

    function drawHandle(ctx, center) {
        var radius = handleSize / 2;
        ctx.beginPath();
        ctx.arc(center.x, center.y, radius, 0, 2 * Math.PI);
        ctx.fill();
    }

    function getHandleAt(x, y) {
        var halfSize = handleSize / 2;
        var handles = [topLeftHandle, topRightHandle, bottomLeftHandle, bottomRightHandle];

        for (var i = 0; i < handles.length; i++) {
            var handle = handles[i];
            if (x >= handle.x - halfSize && x <= handle.x + halfSize && y >= handle.y - halfSize && y <= handle.y + halfSize) {
                return i;
            }
        }
        return -1;
    }

    function constrainRect(rect) {
        // Ensure minimum size
        var width = Math.max(rect.width, minWidth);
        var height = Math.max(rect.height, minHeight);

        // Ensure within canvas bounds
        var x = Math.max(0, Math.min(rect.x, root.width - width));
        var y = Math.max(0, Math.min(rect.y, root.height - height));

        return Qt.rect(x, y, width, height);
    }

    MouseArea {
        anchors.fill: parent

        onPressed: function (mouse) {
            activeHandle = root.getHandleAt(mouse.x, mouse.y);
            if (root.activeHandle >= 0) {
                dragStart = Qt.point(mouse.x, mouse.y);
                initialRect = root.selectionRect;
            }
        }

        // kinda stupid, should maybe bind a mouse area to each handle I don't know
        onPositionChanged: function (mouse) {
            if (root.activeHandle < 0)
                return;

            var dx = mouse.x - root.dragStart.x;
            var dy = mouse.y - root.dragStart.y;
            var newRect;

            switch (root.activeHandle) {
            // top left
            case 0:
                var newX = Math.max(0, Math.min(root.initialRect.x + dx, root.initialRect.x + root.initialRect.width - root.minWidth));
                var newY = Math.max(0, Math.min(root.initialRect.y + dy, root.initialRect.y + root.initialRect.height - minHeight));
                newRect = Qt.rect(newX, newY, root.initialRect.width - (newX - root.initialRect.x), root.initialRect.height - (newY - root.initialRect.y));
                break;
            // top right
            case 1:
                var newY = Math.max(0, Math.min(root.initialRect.y + dy, root.initialRect.y + root.initialRect.height - root.minHeight));
                var newWidth = Math.max(root.minWidth, Math.min(root.initialRect.width + dx, root.width - root.initialRect.x));
                newRect = Qt.rect(root.initialRect.x, newY, newWidth, root.initialRect.height - (newY - root.initialRect.y));
                break;
            // bottom left
            case 2:
                var newX = Math.max(0, Math.min(root.initialRect.x + dx, root.initialRect.x + root.initialRect.width - minWidth));
                var newHeight = Math.max(root.minHeight, Math.min(root.initialRect.height + dy, root.height - root.initialRect.y));
                newRect = Qt.rect(newX, root.initialRect.y, root.initialRect.width - (newX - root.initialRect.x), newHeight);
                break;
            // bottom right
            case 3:
                var newWidth = Math.max(root.minWidth, Math.min(root.initialRect.width + dx, root.width - root.initialRect.x));
                var newHeight = Math.max(root.minHeight, Math.min(root.initialRect.height + dy, root.height - root.initialRect.y));
                newRect = Qt.rect(root.initialRect.x, root.initialRect.y, newWidth, newHeight);
                break;
            }

            selectionRect = root.constrainRect(newRect);
            root.requestPaint();
        }

        onReleased: {
            root.activeHandle = -1;
        }
    }
}
