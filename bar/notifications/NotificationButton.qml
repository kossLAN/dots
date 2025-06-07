pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell.Widgets
import "../.."

Item {
    id: root
    required property var bar
    property var implicitSize: 0
    readonly property real actualSize: Math.min(root.width, root.height)

    implicitWidth: parent.height
    implicitHeight: parent.height

    NotificationCenter {
        id: notificationCenter
    }

    Rectangle {
        color: mouseArea.containsMouse ? ShellSettings.settings.colors["primary"] : "transparent"
        radius: 5

        anchors {
            fill: parent
            margins: 1
        }
    }

    MouseArea {
        id: mouseArea
        hoverEnabled: true
        anchors.fill: parent
        onPressed: {
            if (notificationCenter.visible) {
                notificationCenter.hide();
            } else {
                notificationCenter.show();
            }
        }
    }

    Item {
        implicitWidth: root.implicitSize
        implicitHeight: root.implicitSize
        anchors.centerIn: parent

        layer.enabled: true
        layer.effect: OpacityMask {
            source: Rectangle {
                width: root.actualSize
                height: root.actualSize
                color: "white"
            }

            maskSource: IconImage {
                implicitSize: root.actualSize
                source: "root:resources/general/notification.svg"
            }
        }

        Rectangle {
            color: mouseArea.containsMouse ? ShellSettings.settings.colors["inverse_primary"] : ShellSettings.settings.colors["inverse_surface"]
            anchors.fill: parent
        }
    }

    // TODO: notification number overlay
}
