pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.Pipewire
import "../widgets" as Widgets
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

    // The OSD window will be created and destroyed based on shouldShowOsd.
    // PanelWindow.visible could be set instead of using a loader, but using
    // a loader will reduce the memory overhead when the window isn't open.
    LazyLoader {
        active: root.shouldShowOsd

        PanelWindow {
            // Since the panel's screen is unset, it will be picked by the compositor
            // when the window is created. Most compositors pick the current active monitor.

            anchors.bottom: true
            margins.bottom: 300

            implicitWidth: 400
            implicitHeight: 50
            color: "transparent"

            // An empty click mask prevents the window from blocking mouse events.
            mask: Region {}

            Rectangle {
                anchors.fill: parent
                radius: 8
                color: {
                    let color = ShellSettings.settings.colors["surface"];
                    return Qt.rgba(color.r, color.g, color.b, 0.8);
                }

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 10
                        rightMargin: 15
                    }

                    Widgets.ColoredIcon {
                        implicitSize: 30
                        source: "root:resources/volume/volume-full.svg"
                        color: ShellSettings.settings.colors["inverse_surface"]
                    }

                    Rectangle {
                        id: sliderBackground
                        Layout.fillWidth: true
                        implicitHeight: 10
                        radius: 20
                        color: {
                            let color = ShellSettings.settings.colors["inverse_surface"];
                            return Qt.rgba(color.r, color.g, color.b, 0.5);
                        }

                        layer.enabled: true
                        layer.effect: OpacityMask {
                            source: Rectangle {
                                width: sliderBackground.width
                                height: sliderBackground.height
                                radius: sliderBackground.radius
                                color: "white"
                            }

                            maskSource: Rectangle {
                                width: sliderBackground.width
                                height: sliderBackground.height
                                radius: sliderBackground.radius
                                color: "black"
                            }
                        }

                        Rectangle {
                            color: ShellSettings.settings.colors["primary"]
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
