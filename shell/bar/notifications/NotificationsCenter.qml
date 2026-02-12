pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.widgets
import qs.bar
import qs.notifications

IconButton {
    id: root
    onClicked: showMenu = !showMenu

    source: {
        if (Notifications.hasHiddenNotifications)
            return Quickshell.iconPath("notification-active");

        return Quickshell.iconPath("notification-inactive");
    }

    required property var bar
    property bool showMenu: false

    property PopupItem menu: PopupItem {
        id: menu

        owner: root
        popup: root.bar.popup
        show: root.showMenu
        onClosed: root.showMenu = false
        implicitWidth: 525
        fullHeight: true
        expand: Popup.ExpandRight

        NotificationsViewer {
            menu: menu
            anchors.fill: parent
        }
    }
}
