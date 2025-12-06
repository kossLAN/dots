import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import qs
import qs.widgets

ListView {
    id: root
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
                const timeTracked = notification.timeTracked;

                if (!groups[appName].summaryGroups[summary]) {
                    groups[appName].summaryGroups[summary] = {
                        summary: summary,
                        image: image,
                        timeTracked: timeTracked,
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

                    delegate: StyledRectangle {
                        id: summaryGroup
                        required property var modelData
                        required property int index

                        topLeftRadius: index === 0 ? 12 : 6
                        topRightRadius: index === 0 ? 12 : 6
                        bottomLeftRadius: index === (toastWrapper.modelData.summaryGroups.length - 1) ? 12 : 6
                        bottomRightRadius: index === (toastWrapper.modelData.summaryGroups.length - 1) ? 12 : 6

                        Layout.fillWidth: true
                        Layout.preferredHeight: groupContent.implicitHeight + 24

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
                                            color: ShellSettings.colors.foreground
                                            wrapMode: Text.WordWrap
                                            maximumLineCount: 2
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            id: timeText
                                            color: ShellSettings.colors.foreground.darker(2)
                                            font.pixelSize: 14
                                            Layout.alignment: Qt.AlignVCenter

                                            // poll every minute for updated time
                                            Timer {
                                                interval: 60000
                                                running: true
                                                repeat: true
                                                onTriggered: timeText.text = timeText.getTimeAgoText()
                                            }

                                            function getTimeAgoText() {
                                                const timeTracked = summaryGroup.modelData.timeTracked;

                                                if (timeTracked == undefined)
                                                    return "null";

                                                const currentTime = new Date();
                                                const diffMs = currentTime - timeTracked;

                                                const diffSeconds = Math.floor(diffMs / 1000);
                                                const diffMinutes = Math.floor(diffSeconds / 60);
                                                const diffHours = Math.floor(diffMinutes / 60);
                                                const diffDays = Math.floor(diffHours / 24);

                                                if (diffDays > 0)
                                                    return `${diffDays}d ago`;
                                                if (diffHours > 0)
                                                    return `${diffHours}h ago`;
                                                if (diffMinutes > 0)
                                                    return `${diffMinutes}m ago`;
                                                return "now";
                                            }

                                            text: getTimeAgoText()
                                        }

                                        Item {
                                            Layout.fillWidth: true
                                        }

                                        StyledMouseArea {
                                            Layout.preferredWidth: 18
                                            Layout.preferredHeight: 18
                                            Layout.alignment: Qt.AlignRight

                                            onClicked: {
                                                let notifications = summaryGroup.modelData.notifications;

                                                notifications.forEach(notification => {
                                                    notification.dismiss();
                                                });
                                            }

                                            IconImage {
                                                source: "image://icon/window-close"
                                                anchors.fill: parent
                                            }
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
                                                    color: ShellSettings.colors.foreground
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
