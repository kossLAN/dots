pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects
import "volume" as Volume
import "../../widgets/" as Widgets
import "../.."

// Change to PopupWindow
PopupWindow {
    id: root
    implicitWidth: 400
    implicitHeight: container.height + 10
    color: "transparent"
    visible: container.opacity > 0

    anchor.rect.x: 0
    anchor.rect.y: parentWindow.implicitHeight

    // anchors {
    //     top: true
    //     left: true
    // }

    function show() {
        container.opacity = 1;
        grab.active = true;
    }

    function hide() {
        container.opacity = 0;
        grab.active = false;
    }

    HyprlandFocusGrab {
        id: grab
        windows: [root]
        onCleared: {
            root.hide();
        }
    }

    // Add drop shadow effect
    // Rectangle {
    //     id: shadowSource
    //     color: ShellSettings.colors["surface"]
    //     radius: 8
    //     opacity: container.opacity
    //     width: container.width
    //     height: container.height
    //
    //     anchors {
    //         top: parent.top
    //         left: parent.left
    //         margins: 5
    //     }
    //
    //     layer.enabled: true
    //     layer.effect: DropShadow {
    //         horizontalOffset: 0
    //         verticalOffset: 2
    //         radius: 8.0
    //         samples: 17
    //         color: Qt.rgba(0, 0, 0, 0.5)
    //         transparentBorder: true
    //     }
    //     visible: false // Hide the source rectangle
    // }

    Item {
        id: shadowItem
        anchors.fill: container
        z: container.z - 1
        opacity: container.opacity

        Rectangle {
            id: shadowRect
            anchors.fill: parent
            color: "transparent"

            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 2
                radius: 8.0
                samples: 17
                color: Qt.rgba(0, 0, 0, 0.5)
                source: container
            }
        }
    }

    Rectangle {
        id: container
        color: ShellSettings.colors["surface"]
        radius: 18
        opacity: 0
        width: parent.width - 10
        height: contentColumn.implicitHeight + 20

        anchors {
            top: parent.top
            left: parent.left
            margins: 5
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            id: contentColumn
            spacing: 10

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 10
            }

            // RowLayout {
            //     Layout.fillWidth: true
            //     Layout.preferredHeight: 40
            //
            //     Rectangle {
            //         radius: 20
            //         color: ShellSettings.colors["surface_container_high"]
            //         Layout.fillWidth: true
            //         Layout.fillHeight: true
            //
            //         RowLayout {
            //             anchors {
            //                 fill: parent
            //                 leftMargin: 6
            //             }
            //
            //             ProfileImage {
            //                 id: profileImage
            //                 Layout.preferredWidth: 25
            //                 Layout.preferredHeight: 25
            //                 // implicitWidth: 30
            //                 // implicitHeight: 30
            //             }
            //
            //             Text {
            //                 text: "kossLAN"
            //                 color: ShellSettings.colors["inverse_surface"]
            //                 font.pointSize: 12
            //                 verticalAlignment: Text.AlignVCenter
            //                 Layout.fillWidth: true
            //                 Layout.fillHeight: true
            //                 Layout.margins: 4
            //             }
            //         }
            //     }
            //
            //     Rectangle {
            //         radius: 20
            //         color: ShellSettings.colors["surface_container_high"]
            //         Layout.preferredWidth: powerButtons.implicitWidth + 10
            //         Layout.fillHeight: true
            //
            //         RowLayout {
            //             id: powerButtons
            //             spacing: 10
            //
            //             anchors {
            //                 fill: parent
            //                 leftMargin: 5
            //                 rightMargin: 5
            //             }
            //
            //             Widgets.IconButton {
            //                 id: sleepButton
            //                 implicitSize: 24
            //                 radius: 20
            //                 source: "root:resources/control/sleep.svg"
            //                 onClicked: sleepProcess.running = true
            //             }
            //
            //             Process {
            //                 id: sleepProcess
            //                 running: false
            //                 command: ["hyprctl", "dispatch", "dpms", "off"]
            //             }
            //
            //             Rectangle {
            //                 radius: 20
            //                 color: ShellSettings.colors["surface_bright"]
            //                 Layout.preferredWidth: 2
            //                 Layout.fillHeight: true
            //                 Layout.topMargin: 4
            //                 Layout.bottomMargin: 4
            //             }
            //
            //             Widgets.IconButton {
            //                 id: powerButton
            //                 implicitSize: 24
            //                 radius: 20
            //                 source: "root:resources/control/shutdown.svg"
            //             }
            //         }
            //     }
            // }

            RowLayout {
                spacing: 15
                Layout.fillWidth: true

                Rectangle {
                    color: ShellSettings.colors["surface_container_high"]
                    radius: 12
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                }
            }

            RowLayout {
                spacing: 15
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter

                Repeater {
                    model: [1, 2, 3, 4, 5]
                    delegate: Rectangle {
                        color: ShellSettings.colors["surface_container_high"]
                        radius: width / 2
                        Layout.preferredWidth: 45
                        Layout.preferredHeight: 45
                    }
                }
            }

            ColumnLayout {
                spacing: 10
                Layout.fillWidth: true

                RowLayout {
                    spacing: 10
                    Layout.fillWidth: true
                    Layout.preferredHeight: 55

                    Rectangle {
                        color: ShellSettings.colors["primary"]
                        radius: width / 2
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    Rectangle {
                        color: ShellSettings.colors["primary"]
                        radius: width / 2
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }

                RowLayout {
                    spacing: 10
                    Layout.fillWidth: true
                    Layout.preferredHeight: 55

                    Rectangle {
                        color: ShellSettings.colors["surface_container_high"]
                        radius: width / 2
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    Rectangle {
                        color: ShellSettings.colors["surface_container_high"]
                        radius: width / 2
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }

            Volume.Mixer {
                id: sinkMixer
                isSink: true
                Layout.fillWidth: true
            }

            Volume.Mixer {
                id: sourceMixer
                isSink: false
                Layout.fillWidth: true
            }

            MediaPlayer {
                player: Mpris.players?.values[0]
                visible: Mpris.players?.values.length != 0
                Layout.fillWidth: true
                Layout.preferredHeight: 150
            }
        }
    }
}
