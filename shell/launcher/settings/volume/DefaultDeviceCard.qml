pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import qs
import qs.widgets

StyledRectangle {
    id: root
    clip: true
    color: ShellSettings.colors.active.base

    required property string title
    required property string icon
    required property string mutedIcon
    required property PwNode node

    Layout.fillWidth: true
    Layout.preferredHeight: content.implicitHeight + 16

    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: root.width
            height: root.height
            radius: root.radius
            color: "black"
        }
    }

    PwNodePeakMonitor {
        id: peakMonitor
        node: root.node
    }

    ColumnLayout {
        id: content
        spacing: 6

        anchors {
            fill: parent
            margins: 6
        }

        RowLayout {
            spacing: 6
            Layout.fillWidth: true

            IconImage {
                source: Quickshell.iconPath(root.icon)
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
            }

            ColumnLayout {
                spacing: 1
                Layout.fillWidth: true

                StyledText {
                    text: root.title
                    font.pointSize: 9
                }

                StyledText {
                    text: root.node ? (root.node.nickname || root.node.description) : "No device"
                    color: ShellSettings.colors.active.windowText.darker(1.5)
                    font.pointSize: 9
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            Item {
                Layout.fillWidth: true
            }

            StyledMouseArea {
                enabled: root.node?.audio !== null
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24

                onClicked: {
                    if (root.node?.audio) {
                        root.node.audio.muted = !root.node.audio.muted;
                    }
                }

                IconImage {
                    anchors.fill: parent
                    source: {
                        if (root.node?.audio?.muted) {
                            return Quickshell.iconPath(root.mutedIcon);
                        } else if (root.node?.audio && root.node.audio.volume > 0.66) {
                            return Quickshell.iconPath("audio-volume-high");
                        } else if (root.node?.audio && root.node.audio.volume > 0.33) {
                            return Quickshell.iconPath("audio-volume-medium");
                        } else {
                            return Quickshell.iconPath("audio-volume-low");
                        }
                    }
                }
            }
        }

        Rectangle {
            color: ShellSettings.colors.active.light
            radius: 2

            Layout.fillWidth: true
            Layout.preferredHeight: 3
            Layout.leftMargin: 6
            Layout.rightMargin: 6

            Rectangle {
                width: parent.width * peakMonitor.peak
                height: parent.height
                radius: parent.radius
                color: ShellSettings.colors.active.highlight

                Behavior on width {
                    SmoothedAnimation {
                        duration: 50
                    }
                }
            }
        }

        StyledSlider {
            implicitHeight: 6
            handleHeight: 12
            value: root.node?.audio?.volume ?? 0

            Layout.fillWidth: true
            Layout.leftMargin: 6
            Layout.rightMargin: 6
            Layout.bottomMargin: 6

            onValueChanged: {
                if (!root.node || !root.node.audio || !root.node.ready)
                    return;
                root.node.audio.volume = value;
            }
        }
    }
}
