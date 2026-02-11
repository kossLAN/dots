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
        implicitWidth: 950
        implicitHeight: 600

        ChatManager {
            anchors {
                fill: parent
                margins: 8
            }
        }

        StyledRectangle {
            color: ShellSettings.colors.active.mid
            implicitHeight: switcherParent.implicitHeight + 8
            implicitWidth: switcherParent.implicitWidth + 8

            anchors {
                right: parent.right
                top: parent.top
                margins: 8
            }

            Item {
                id: switcherParent
                anchors.centerIn: parent
                implicitWidth: childrenRect.width
                implicitHeight: childrenRect.height
            }
        }
    }
}
