pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Item {
    id: root

    property real toastWidth: 525
    property real overshoot: 20

    property alias stack: stack

    property Region mask: Region {
        item: root.stack
    }

    Item {
        anchors.fill: parent

        ToastStack {
            id: stack
            spacing: 4

            Repeater {
                model: ScriptModel {
                    values: Notifications.notifications.filter(n => !n.hidden)
                }

                delegate: Toast {
                    id: toast

                    required property NotificationBacker modelData

                    backer: modelData ?? null
                    view: root

                    Component.onCompleted: playEnter()
                }
            }
        }
    }
}
