pragma ComponentBehavior: Bound

import QtQuick

import qs
import qs.widgets
import qs.launcher

LauncherBacker {
    id: root
    enabled: ShellSettings.settings.chatEnabled
    icon: "applications-chat-panel"
    switcherParent: switcherParent

    content: Item {
        id: container
        implicitWidth: resizeArea.currentSize.width
        implicitHeight: resizeArea.currentSize.height

        // Only load if visible, resource intensive, and problem occur loading in the
        // background
        Loader {
            active: container.parent != null
            sourceComponent: ChatManager {}
            focus: true
            anchors.fill: parent
        }

        StyledRectangle {
            color: ShellSettings.colors.active.mid
            implicitHeight: switcherParent.implicitHeight + 8
            implicitWidth: switcherParent.implicitWidth + 8

            anchors {
                right: parent.right
                top: parent.top
                margins: 4
            }

            Item {
                id: switcherParent
                anchors.centerIn: parent
                implicitWidth: childrenRect.width
                implicitHeight: childrenRect.height
            }
        }

        MouseArea {
            id: resizeArea
            width: 12
            height: 12
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            cursorShape: Qt.SizeFDiagCursor

            property size startSize
            property size currentSize: Qt.size(ShellSettings.sizing.chatSize.width, ShellSettings.sizing.chatSize.height)

            drag.target: Item {
                id: dragTarget
                x: 0
                y: 0
            }
            drag.axis: Drag.XAndYAxis

            onPressed: {
                root.animate = false;
                startSize = Qt.size(container.implicitWidth, container.implicitHeight);
                currentSize = startSize;
                dragTarget.x = 0;
                dragTarget.y = 0;
            }

            onPositionChanged: {
                if (pressed) {
                    var newWidth = Math.max(400, startSize.width + dragTarget.x);
                    var newHeight = Math.max(300, startSize.height + dragTarget.y);
                    currentSize = Qt.size(newWidth, newHeight);
                }
            }

            onReleased: {
                ShellSettings.sizing.chatSize.width = currentSize.width;
                ShellSettings.sizing.chatSize.height = currentSize.height;
                root.animate = true;
            }
        }
    }
}
