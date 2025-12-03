pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell

Scope {
    id: root

    Connections {
        target: Notifications.notificationServer

        function onNotification(notification) {
            notification.timeTracked = new Date();
            notification.toastSuppressed = NotificationCenter.notificationsOpen;

            if (!notification.toastSuppressed) {
                notificationLoader.item.visible = true;
            }
        }
    }

    LazyLoader {
        id: notificationLoader
        loading: true

        PanelWindow {
            id: notificationWindow
            color: "transparent"
            implicitWidth: 500
            exclusionMode: ExclusionMode.Normal

            property var visibleCount: {
                let count = 0;

                for (let i = 0; i < toastList.count; i++) {
                    let item = toastList.itemAt(i);

                    if (item && item.visible) {
                        count++;
                    }
                }

                return count;
            }

            onVisibleCountChanged: visible = visibleCount != 0
            visible: true

            mask: Region {
                item: notifLayout
            }

            anchors {
                top: true
                bottom: true
                right: true
            }

            ColumnLayout {
                id: notifLayout
                spacing: 4

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 5
                }

                Repeater {
                    id: toastList

                    model: ScriptModel {
                        values: Notifications.notificationServer.trackedNotifications.values
                            .filter(notification => !notification.toastSuppressed)
                            .concat()
                    }

                    delegate: ActiveToast {
                        id: toast
                        required property var modelData
                        notification: modelData

                        Connections {
                            target: toast

                            function onExpired(notification) {
                                toast.visible = false;
                            }

                            function onClosed(notification) {
                                notification.dismiss();
                            }
                        }
                    }
                }
            }
        }
    }
}
