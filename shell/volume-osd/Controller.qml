pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import ".."

Scope {
    id: root

    // Bind the pipewire node so its volume will be tracked
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Connections {
        target: Pipewire.defaultAudioSink?.audio

        function onVolumeChanged() {
            root.shouldShowOsd = true;
            hideTimer.restart();
        }
    }

    property bool shouldShowOsd: false

    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: root.shouldShowOsd = false
    }

    LazyLoader {
        active: root.shouldShowOsd

        PopupWindow {
            implicitWidth: 50
            implicitHeight: 275
            color: "transparent"

            // An empty click mask prevents the window from blocking mouse events.
            mask: Region {}

            Rectangle {
                anchors.fill: parent
                radius: 8
                color: {
                    let color = ShellSettings.colors["surface"];
                    return Qt.rgba(color.r, color.g, color.b, 0.8);
                }

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 10
                        rightMargin: 15
                    }

                    IconImage {
                        implicitSize: 30
                        source: "root:resources/volume/volume-full.svg"
                    }

                    Rectangle {
                        id: sliderBackground
                        Layout.fillWidth: true
                        implicitHeight: 10
                        radius: 20
                        color: {
                            let color = ShellSettings.colors["inverse_surface"];
                            return Qt.rgba(color.r, color.g, color.b, 0.5);
                        }

                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: sliderBackground.width
                                height: sliderBackground.height
                                radius: sliderBackground.radius
                                color: "black"
                            }
                        }

                        Rectangle {
                            color: ShellSettings.colors["primary"]
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }

                            implicitWidth: parent.width * (Pipewire.defaultAudioSink?.audio.volume ?? 0)
                        }
                    }
                }
            }
        }
    }
}
