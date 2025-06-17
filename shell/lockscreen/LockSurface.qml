pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import ".."

Rectangle {
    id: root
    color: Window.active ? ShellSettings.colors["surface"] : ShellSettings.colors["surface_dim"]
    required property LockContext context

    Item {
        anchors.fill: parent

        Image {
            id: bgImage
            source: ShellSettings.settings.wallpaperUrl
            fillMode: Image.PreserveAspectCrop
            anchors.fill: parent
            visible: false
        }

        FastBlur {
            anchors.fill: bgImage
            source: bgImage
            radius: 80
            transparentBorder: true
        }

        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.3
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(0, 0, 0, 0.2)
                }
                GradientStop {
                    position: 0.5
                    color: Qt.rgba(0, 0, 0, 0.1)
                }
                GradientStop {
                    position: 1.0
                    color: Qt.rgba(0, 0, 0, 0.4)
                }
            }
        }
    }

    // Date and time display
    ColumnLayout {
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 120
        }
        spacing: 10

        Text {
            id: clock
            horizontalAlignment: Text.AlignHCenter
            renderType: Text.NativeRendering
            font.pointSize: 72
            font.weight: Font.Light
            color: "white"
            text: {
                const now = this.date;
                let hours = now.getHours();
                const minutes = now.getMinutes().toString().padStart(2, '0');
                const ampm = hours >= 12 ? 'PM' : 'AM';
                hours = hours % 12;
                hours = hours ? hours : 12; // 0 should be 12
                return `${hours}:${minutes}`;
            }

            property var date: new Date()
            Layout.alignment: Qt.AlignHCenter

            Timer {
                running: true
                repeat: true
                interval: 1000
                onTriggered: clock.date = new Date()
            }

            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 0
                radius: 20
                samples: 41
                color: Qt.rgba(1, 1, 1, 0.3)
            }
        }
    }

    // login section
    ColumnLayout {
        visible: Window.active
        anchors.centerIn: parent
        spacing: 30

        Rectangle {
            id: profileImage
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 120
            Layout.preferredHeight: 120

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: profileImage.width
                    height: profileImage.height
                    radius: width / 2
                    color: "black"
                }
            }

            Image {
                source: "root:resources/general/pfp.png"
                anchors.fill: parent
            }
        }

        // password input, should probably split this out into a seperate comp
        LoginField {
            id: passwordBox
            enabled: !root.context.unlockInProgress

            Layout.preferredWidth: 250
            Layout.preferredHeight: 30
            Layout.maximumHeight: 30
            Layout.alignment: Qt.AlignHCenter

            onTextChanged: root.context.currentText = this.text
            onAccepted: root.context.tryUnlock()

            Connections {
                target: root.context

                function onCurrentTextChanged() {
                    if (!passwordBox.shaking) {
                        passwordBox.text = root.context.currentText;
                    }
                }

                function onShowFailureChanged() {
                    if (root.context.showFailure && !passwordBox.shaking) {
                        passwordBox.shaking = true;
                    }
                }
            }
        }
    }

    // hint text
    Text {
        text: "Press Enter to unlock"
        color: Qt.rgba(1, 1, 1, 0.5)
        font.pointSize: 12
        horizontalAlignment: Text.AlignHCenter
        opacity: passwordBox.text.length > 0 ? 1.0 : 0.0

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 60
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
            }
        }
    }

    // testing button
    Button {
        visible: false
        text: "Emergency Unlock"
        onClicked: root.context.unlocked()

        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: 20
        }
    }
}
