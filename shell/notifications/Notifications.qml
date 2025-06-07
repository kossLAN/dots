pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import QtQml.Models
import Quickshell

Singleton {
    id: root

    property bool blockToasts: false
    property alias doNotDisturb: persist.doNotDisturb

    PersistentProperties {
        id: persist

        property bool doNotDisturb: false
    }

    // Handle discarded signal for all notifications
    // For ApplicationNotificationBackers, this runs after serverNotification.dismiss()
    // which triggers onObjectRemoved, but removeNotification is idempotent
    Instantiator {
        model: [...root.notifications]

        Connections {
            required property NotificationBacker modelData

            target: modelData

            function onDiscarded() {
                root.removeNotification(target);
            }
        }
    }

    property bool hasHiddenNotifications: hiddenNotifications.length != 0

    property list<NotificationBacker> hiddenNotifications: notifications.filter(x => {
        return x?.hidden ?? false;
    })

    property int notificationId: 0

    property list<NotificationBacker> notifications: []

    function addNotification(notification: NotificationBacker) {
        notification.notificationId = ++notificationId;
        notifications.push(notification);

        // If we block toasts don't spawn a toast, and set backer to hidden state
        if (root.doNotDisturb || root.blockToasts) {
            notification.hidden = true;
        }
    }

    function removeNotification(notification: NotificationBacker) {
        root.notifications = root.notifications.filter(n => n !== notification);
    }

    // Handles the create of application notifications
    ApplicationNotifications {}

    NotificationPanel {
        id: panel
        visible: root.notifications.some(n => !n.hidden) && (!root.blockToasts && !root.doNotDisturb)
    }

    // Needs to be loaded, for notifications to work properly
    function init() {
    }
}
