pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    property alias notificationsOpen: persist.notificationsOpen
    property alias api: ipc
    property var bar

    PersistentProperties {
        id: persist
        property bool notificationsOpen: false
    }

    IpcHandler {
        id: ipc
        target: "notifications"

        function open(): void {
            persist.notificationsOpen = true;
        }

        function close(): void {
            persist.notificationsOpen = false;
        }

        function toggle(): void {
            persist.notificationsOpen = !persist.notificationsOpen;
        }
    }

    LazyLoader {
        id: loader
        activeAsync: persist.notificationsOpen

        PanelWindow {
            id: notificationPanel
            color: "transparent"
            implicitWidth: 500
            exclusionMode: ExclusionMode.Normal
            visible: persist.notificationsOpen

            anchors {
                top: true
                right: true
                bottom: true
            }

            mask: Region {
                item: notificationsView
            }

            HyprlandFocusGrab {
                id: grab
                active: true
                windows: [notificationPanel, root.bar]
                onCleared: {
                    root.notificationsOpen = false;
                }
            }

            Item {
                id: container
                anchors.fill: parent

                ColumnLayout {
                    id: panelColumn

                    anchors {
                        fill: parent
                        margins: 4
                    }

                    NotificationsView {
                        id: notificationsView
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.min(parent.height, contentHeight)
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }

    function init() {
    }
}
