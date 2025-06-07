import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import "../widgets/" as Widgets
import ".."
import "../.."

Rectangle {
    id: notificationRoot
    required property var notification
    radius: 5
    color: ShellGlobals.colors.base
    width: parent.width
    height: column.implicitHeight + 30

    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        spread: 0.01
        samples: 25
        color: "#80000000"
    }

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
                        notification.expire();
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
        id: column
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

                IconImage {
                    visible: notification.appIcon != ""
                    source: Quickshell.iconPath(notification.appIcon)
                    implicitSize: 24
                }

                RowLayout {
                    Text {
                        id: appName
                        text: notification.appName
                        color: ShellGlobals.colors.text
                        font.pointSize: 11
                        font.bold: true
                        wrapMode: Text.Wrap
                        Layout.fillWidth: false
                    }

                    Widgets.Separator {}

                    Text {
                        id: summaryText
                        text: notification.summary
                        color: ShellGlobals.colors.text
                        font.pointSize: 11
                        wrapMode: Text.Wrap
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
                            ctx.strokeStyle = ShellGlobals.colors.accent;
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
                        onPressed: {
                            notification.dismiss();
                        }
                    }

                    IconImage {
                        source: "image://icon/window-close"
                        implicitSize: 16
                        anchors.centerIn: parent
                    }
                }
            }

            RowLayout {
                ColumnLayout {
                    Text {
                        id: bodyText
                        text: notification.body
                        color: ShellGlobals.colors.text
                        font.pointSize: 11
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
