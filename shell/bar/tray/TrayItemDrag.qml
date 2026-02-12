import QtQuick

Item {
    id: root

    required property var modelData
    required property var rootRef
    required property string dragKey

    property bool isDragging: rootRef.draggedItem === modelData

    signal clicked()
    signal dragComplete(string action, var item)

    width: parent.width
    height: parent.height

    MouseArea {
        id: mouseArea
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        drag.target: dragItem
        drag.axis: Drag.XAndYAxis
        drag.threshold: 5

        onClicked: root.clicked()

        onPressedChanged: function() {
            if (!pressed) {
                if (root.isDragging) {
                    dragItem.Drag.drop();
                    root.dragComplete("drop", root.modelData);
                }

                dragItem.x = 0;
                dragItem.y = 0;
            }
        }
    }

    Item {
        id: dragItem
        width: root.width
        height: root.height
        visible: root.isDragging

        Drag.active: root.isDragging
        Drag.keys: [root.dragKey]
        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: height / 2

        onXChanged: {
            if (mouseArea.pressed && mouseArea.drag.active && rootRef.draggedItem === null) {
                rootRef.draggedItem = root.modelData;
            }
        }

        Item {
            opacity: 0.55
            anchors.fill: parent

            Loader {
                active: root.modelData.icon
                sourceComponent: root.modelData.icon
                anchors.fill: parent
                anchors.margins: 2
            }
        }
    }
}
