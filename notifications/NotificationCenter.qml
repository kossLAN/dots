pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import "../widgets" as Widgets
import ".."

Singleton {
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
            color: "red"
            implicitWidth: 500
            exclusionMode: ExclusionMode.Normal
            // WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            anchors {
                top: true
                right: true
                bottom: true
            }

            ColumnLayout {
                spacing: 10

                anchors {
                    fill: parent
                    margins: 10
                }

                Text {
                    text: "Notifications: " + toastList.count
                    Layout.fillWidth: true
                }

                ListView {
                    id: toastList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 5

                    model: ScriptModel {
                        values: {
                            const notifications = Notifications.notificationServer.trackedNotifications.values.concat();

                            const groupedByApp = notifications.reduce((groups, notification) => {
                                const appName = notification.appName;

                                if (!groups[appName]) {
                                    groups[appName] = {
                                        appName: appName,
                                        summaryGroups: {}
                                    };
                                }

                                const summary = notification.summary;
                                const image = notification.image;

                                if (!groups[appName].summaryGroups[summary]) {
                                    groups[appName].summaryGroups[summary] = {
                                        summary: summary,
                                        image: image,
                                        notifications: []
                                    };
                                }

                                groups[appName].summaryGroups[summary].notifications.push(notification);

                                return groups;
                            }, {});

                            return Object.values(groupedByApp).map(appGroup => {
                                return {
                                    appName: appGroup.appName,
                                    summaryGroups: Object.values(appGroup.summaryGroups)
                                };
                            });
                        }
                    }

                    delegate: Item {
                        id: toastWrapper
                        required property var modelData
                        width: ListView.view.width
                        height: toastContent.height

                        Item {
                            id: toastContent
                            width: parent.width
                            height: contentColumn.implicitHeight
                            anchors.centerIn: parent

                            ColumnLayout {
                                id: contentColumn
                                spacing: 2

                                anchors {
                                    fill: parent
                                    margins: 0
                                }

                                // Notification content
                                Repeater {
                                    model: toastWrapper.modelData.summaryGroups

                                    delegate: Rectangle {
                                        id: summaryGroup
                                        required property var modelData
                                        required property int index
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: groupContent.implicitHeight + 24
                                        color: ShellSettings.colors["surface_container"]
                                        antialiasing: true

                                        topLeftRadius: index === 0 ? 25 : 5
                                        topRightRadius: index === 0 ? 25 : 5
                                        bottomLeftRadius: index === (toastWrapper.modelData.summaryGroups.length - 1) ? 25 : 5
                                        bottomRightRadius: index === (toastWrapper.modelData.summaryGroups.length - 1) ? 25 : 5

                                        ColumnLayout {
                                            id: groupContent
                                            spacing: 8

                                            anchors {
                                                fill: parent
                                                margins: 12
                                            }

                                            RowLayout {
                                                spacing: 12
                                                Layout.fillWidth: true
                                                Layout.alignment: Qt.AlignTop

                                                ColumnLayout {
                                                    Layout.alignment: Qt.AlignTop
                                                    spacing: 0

                                                    Item {
                                                        id: imageContainer
                                                        Layout.preferredWidth: 36
                                                        Layout.preferredHeight: 36
                                                        visible: summaryGroup.modelData.image != ""
                                                        antialiasing: true

                                                        Image {
                                                            id: notificationImage
                                                            anchors.fill: parent
                                                            source: summaryGroup.modelData.image
                                                            fillMode: Image.PreserveAspectCrop

                                                            layer.enabled: true
                                                            layer.effect: OpacityMask {
                                                                maskSource: Rectangle {
                                                                    width: notificationImage.width
                                                                    height: notificationImage.height
                                                                    radius: notificationImage.width / 2
                                                                    antialiasing: true
                                                                }
                                                            }
                                                        }
                                                    }
                                                }

                                                // Content column
                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    Layout.alignment: Qt.AlignTop
                                                    spacing: 8

                                                    // Header row
                                                    RowLayout {
                                                        Layout.fillWidth: true
                                                        spacing: 8

                                                        Text {
                                                            text: summaryGroup.modelData.summary
                                                            font.pixelSize: 16
                                                            font.weight: Font.Medium
                                                            color: ShellSettings.colors["on_surface"]
                                                            wrapMode: Text.WordWrap
                                                            maximumLineCount: 2
                                                            elide: Text.ElideRight
                                                        }

                                                        Widgets.Separator {}

                                                        Text {
                                                            text: "now"
                                                            font.pixelSize: 14
                                                            color: ShellSettings.colors["on_surface_variant"]
                                                            Layout.alignment: Qt.AlignVCenter
                                                        }
                                                    }

                                                    // Notification bodies
                                                    ColumnLayout {
                                                        Layout.fillWidth: true
                                                        spacing: 2

                                                        Repeater {
                                                            model: summaryGroup.modelData.notifications

                                                            delegate: ColumnLayout {
                                                                id: bodyDelegate
                                                                required property var modelData
                                                                required property int index
                                                                Layout.fillWidth: true
                                                                spacing: 0

                                                                Text {
                                                                    Layout.fillWidth: true
                                                                    text: bodyDelegate.modelData.body
                                                                    font.pixelSize: 14
                                                                    color: ShellSettings.colors["on_surface_variant"]
                                                                    wrapMode: Text.WordWrap
                                                                    maximumLineCount: 4
                                                                    elide: Text.ElideRight
                                                                    lineHeight: 1.3
                                                                    visible: bodyDelegate.modelData.body != ""
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // HyprlanFocusGrab {
            //     id: grab
            //     windows: [notificationPanel]
            //     onCleared: {
            //         ipc.hide();
            //     }
            // }
        }
    }

    function init() {
    }
}
