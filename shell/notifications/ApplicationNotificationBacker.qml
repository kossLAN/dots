pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import QtQuick
import Qt5Compat.GraphicalEffects

import qs

NotificationBacker {
    id: root

    required property Notification serverNotification
    property int closeAnimDuration: 10000

    summary: serverNotification?.summary ?? ""

    body: Text {
        visible: root.serverNotification.body != ""
        color: ShellSettings.colors.active.text.darker(1.25)
        font.weight: Font.Normal
        font.pixelSize: 12
        wrapMode: Text.WrapAnywhere
        elide: Text.ElideRight
        maximumLineCount: 6

        text: root.serverNotification.body
    }

    icon: Item {
        id: imageContainer

        property bool hasImage: notificationImage !== "" || appIconSource !== ""
        property bool hasActualImage: root.serverNotification?.image !== "" ?? false

        property string notificationImage: {
            if (!root.serverNotification)
                return "";

            if (root.serverNotification.image !== "")
                return root.serverNotification.image;

            if (root.serverNotification.appIcon !== "") {
                if (root.serverNotification.appIcon.startsWith("/") || root.serverNotification.appIcon.startsWith("file://"))
                    return root.serverNotification.appIcon;

                return Quickshell.iconPath(root.serverNotification.appIcon);
            }

            return "";
        }

        property string appIconSource: {
            if (!root.serverNotification)
                return "";

            if (root.serverNotification.desktopEntry !== "") {
                const entry = DesktopEntries.byId(root.serverNotification.desktopEntry);

                if (entry?.icon)
                    return Quickshell.iconPath(entry.icon);
            }

            if (root.serverNotification.appName !== "") {
                const entry = DesktopEntries.byId(root.serverNotification.appName.toLowerCase());

                if (entry?.icon)
                    return Quickshell.iconPath(entry.icon);
            }

            return "";
        }

        visible: hasImage
        width: 36
        height: 36

        anchors {
            left: parent.left
            top: parent.top
        }

        Image {
            id: mainImage
            fillMode: Image.PreserveAspectCrop
            anchors.fill: parent

            source: {
                if (imageContainer.notificationImage !== "")
                    return imageContainer.notificationImage;
                else
                    return imageContainer.appIconSource;
            }

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: mainImage.width
                    height: mainImage.height
                    radius: mainImage.width / 2
                }
            }
        }

        IconImage {
            visible: imageContainer.hasActualImage && imageContainer.appIconSource !== ""
            width: 18
            height: 18
            anchors.right: parent.right
            anchors.rightMargin: -4
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -4
            source: imageContainer.appIconSource
        }
    }

    buttons: CloseButton {
        paused: root.hovered
        duration: root.closeAnimDuration
        implicitHeight: 20
        implicitWidth: 20

        onFinished: root.hide()
        onClicked: root.discard()
    }
}
