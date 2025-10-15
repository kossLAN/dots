pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import qs
import qs.widgets

Scope {
    id: root

    // Bind the pipewire node so its volume will be tracked
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Connections {
        target: Pipewire.defaultAudioSink?.audio

        function onVolumeChanged() {
            console.log("Volume Changed, showing OSD.");
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

        PanelWindow {
            implicitWidth: 250
            implicitHeight: 50
            color: "transparent"
            exclusiveZone: 0
            visible: true
            mask: Region {}
            anchors.bottom: true
            margins.bottom: screen.height / 10

            StyledRectangle {
                anchors.fill: parent
                // radius: 8

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
                        color: ShellSettings.colors.inactive

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
                            color: ShellSettings.colors.active
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
