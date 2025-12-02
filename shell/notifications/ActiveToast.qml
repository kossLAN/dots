import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs
import qs.widgets

Item {
    id: root
    required property var notification
    signal expired(Notification notification)
    signal closed(Notification notification)

    width: parent.width
    height: Math.min(row.implicitHeight + 30, 400)

    StyledRectangle {
        id: container
        radius: 10
        color: ShellSettings.colors.background
        anchors.fill: parent

        Item {
            id: timerController
            property int totalDuration: 5000
            property int remainingTime: totalDuration
            property bool isRunning: false
            property real lastTime: 0

            Timer {
                id: internalTimer
                interval: 16
                repeat: true
                running: timerController.isRunning

                onTriggered: {
                    var currentTime = Date.now();
                    if (timerController.lastTime > 0) {
                        var delta = currentTime - timerController.lastTime;
                        timerController.remainingTime -= delta;
                        if (timerController.remainingTime <= 0) {
                            timerController.isRunning = false;
                            root.expired(root.notification);
                        }
                    }
                    timerController.lastTime = currentTime;
                }
            }

            function start() {
                if (!isRunning) {
                    lastTime = Date.now();
                    isRunning = true;
                }
            }

            function pause() {
                isRunning = false;
                lastTime = 0;
            }

            Component.onCompleted: {
                start();
            }
        }

        MouseArea {
            id: notificationArea
            hoverEnabled: true
            anchors.fill: parent

            onContainsMouseChanged: {
                progressAnimation.paused = containsMouse;
                if (containsMouse) {
                    timerController.pause();
                } else {
                    timerController.start();
                }
            }
        }

        RowLayout {
            id: row
            spacing: 5

            anchors {
                fill: parent
                margins: 15
            }

            ColumnLayout {
                Layout.fillWidth: true

                RowLayout {
                    id: topRow
                    spacing: 10
                    Layout.fillWidth: true

                    IconImage {
                        visible: root.notification.appIcon != ""
                        source: Quickshell.iconPath(root.notification.appIcon)
                        implicitSize: 24
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            id: appName
                            text: root.notification.appName
                            color: ShellSettings.colors.foreground
                            font.pointSize: 11
                            font.bold: true
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            // Layout.preferredWidth: implicitWidth
                            // Layout.maximumWidth: topRow.width * 0.3
                        }

                        Text {
                            id: summaryText
                            text: root.notification.summary
                            color: ShellSettings.colors.foreground
                            font.pointSize: 11
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            Layout.fillWidth: true
                        }
                    }

                    Item {
                        id: closeButton
                        width: 24
                        height: 24
                        Layout.alignment: Qt.AlignTop

                        Canvas {
                            id: progressCircle
                            anchors.fill: parent
                            antialiasing: true

                            property real progress: 1.0
                            onProgressChanged: requestPaint()

                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();

                                var centerX = width / 2;
                                var centerY = height / 2;
                                var radius = Math.min(width, height) / 2 - 2;

                                ctx.beginPath();
                                ctx.arc(centerX, centerY, radius, -Math.PI / 2, -Math.PI / 2 + 2 * Math.PI * progress);
                                ctx.strokeStyle = ShellSettings.colors.highlight
                                ctx.lineWidth = 2;
                                ctx.stroke();
                            }
                        }

                        NumberAnimation {
                            id: progressAnimation
                            target: progressCircle
                            property: "progress"
                            from: 1.0
                            to: 0.0
                            duration: 5000
                            running: true
                            easing.type: Easing.Linear
                        }

                        Rectangle {
                            id: closeButtonBg
                            anchors.centerIn: parent
                            width: 16
                            height: 16
                            color: "#FF474D"
                            radius: 10
                            visible: closeButtonArea.containsMouse
                        }

                        MouseArea {
                            id: closeButtonArea
                            hoverEnabled: true
                            anchors.fill: parent
                            onPressed: root.closed(root.notification)
                        }

                        IconImage {
                            source: "image://icon/window-close"
                            implicitSize: 16
                            anchors.centerIn: parent
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true

                    Text {
                        id: bodyText
                        text: root.notification.body
                        color: ShellSettings.colors.foreground
                        font.pointSize: 11
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                        maximumLineCount: 10
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
