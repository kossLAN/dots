pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import qs
import qs.bar
import qs.widgets
import qs.notifications

Item {
    id: root

    required property PopupItem menu

    ColumnLayout {
        spacing: 4
        anchors.fill: parent

        RowLayout {
            spacing: 8

            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            // Layout.margins: 8

            RowLayout {
                spacing: 8

                StyledText {
                    text: "Do Not Disturb"
                    font.pointSize: 10
                    color: ShellSettings.colors.active.windowText
                }

                ToggleSwitch {
                    checked: Notifications.doNotDisturb
                    onCheckedChanged: Notifications.doNotDisturb = checked
                }
            }

            Item {
                Layout.fillWidth: true
            }

            StyledButton {
                color: ShellSettings.colors.active.alternateBase
                visible: Notifications.hasHiddenNotifications
                radius: 10

                Layout.preferredWidth: clearRow.width + 16
                Layout.preferredHeight: 28

                onClicked: notificationsList.clearNotifications()

                RowLayout {
                    id: clearRow
                    anchors.centerIn: parent
                    spacing: 4

                    IconImage {
                        source: Quickshell.iconPath("trash-empty")
                        implicitSize: 16
                    }

                    StyledText {
                        text: "Clear All"
                        font.pointSize: 10
                        color: ShellSettings.colors.active.windowText
                    }
                }
            }
        }

        Separator {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
        }

        Item {
            clip: true

            Layout.fillWidth: true
            Layout.fillHeight: true

            NotificationsList {
                id: notificationsList
                menu: root.menu
                visible: Notifications.hasHiddenNotifications

                anchors {
                    fill: parent
                    margins: 8
                }
            }

            ColumnLayout {
                id: notificationsInfo
                anchors.centerIn: parent
                spacing: 12
                visible: !Notifications.hasHiddenNotifications

                onVisibleChanged: showAnim.restart()

                IconImage {
                    Layout.alignment: Qt.AlignHCenter
                    source: Quickshell.iconPath("notifications")
                    implicitWidth: 48
                    implicitHeight: 48
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: "No notifications"
                    font.pointSize: 11
                    color: ShellSettings.colors.active.windowText.darker(1.5)
                }

                NumberAnimation {
                    id: showAnim
                    target: notificationsInfo
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 1000
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
