pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import qs
import qs.widgets
import qs.bar
import qs.services.gsr

StyledMouseArea {
    id: root
    onClicked: showMenu = !showMenu
    visible: ShellSettings.settings.gsrEnabled

    required property var bar
    property bool showMenu: false

    Rectangle {
        radius: height / 2
        color: "#DFDFDF"
        opacity: GpuScreenRecord.isRunning ? 1 : 0.25

        SequentialAnimation on opacity {
            running: GpuScreenRecord.isRunning
            loops: Animation.Infinite

            NumberAnimation {
                from: 1.0
                to: 0.3
                duration: 800
                easing.type: Easing.InOutQuad
            }

            NumberAnimation {
                from: 0.3
                to: 1.0
                duration: 800
                easing.type: Easing.InOutQuad
            }
        }

        anchors {
            fill: parent
            margins: 6
        }
    }

    property PopupItem menu: PopupItem {
        id: menu
        owner: root
        popup: root.bar.popup
        show: root.showMenu
        onClosed: root.showMenu = false
        implicitWidth: 280
        implicitHeight: container.implicitHeight + (2 * container.anchors.margins)

        property real entryHeight: 32

        ColumnLayout {
            id: container
            spacing: 4

            anchors {
                fill: parent
                margins: 8
            }

            RowLayout {
                spacing: 8
                Layout.fillWidth: true 
                // Layout.margins: 4

                Rectangle {
                    radius: height / 2
                    color: "#DFDFDF"
                    opacity: GpuScreenRecord.isRunning ? 1 : 0.25

                    Layout.preferredHeight: 12
                    Layout.preferredWidth: 12
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10

                    SequentialAnimation on opacity {
                        running: GpuScreenRecord.isRunning
                        loops: Animation.Infinite

                        NumberAnimation {
                            from: 1.0
                            to: 0.3
                            duration: 800
                            easing.type: Easing.InOutQuad
                        }

                        NumberAnimation {
                            from: 0.3
                            to: 1.0
                            duration: 800
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

                ColumnLayout {
                    spacing: 0
                    Layout.fillWidth: true

                    StyledText {
                        color: ShellSettings.colors.active.windowText
                        text: GpuScreenRecord.isRunning ? (GpuScreenRecord.isReplayMode ? "Replay Active" : "Recording") : "Screen Recorder"
                    }

                    StyledText {
                        color: ShellSettings.colors.active.windowText.darker(1.5)
                        text: GpuScreenRecord.isRunning ? `${GpuScreenRecord.config.codec.toUpperCase()} ${GpuScreenRecord.config.fps}fps` : "Click to start"
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                ToggleSwitch {
                    checked: GpuScreenRecord.config.enabled
                    onCheckedChanged: {
                        GpuScreenRecord.config.enabled = checked;
                    }
                }
            }

            // Save replay button
            StyledMouseArea {
                id: saveReplayButton
                visible: GpuScreenRecord.isRunning && GpuScreenRecord.isReplayMode
                color: containsMouse ? ShellSettings.colors.active.highlight : ShellSettings.colors.active.button
                radius: 6

                Layout.fillWidth: true
                Layout.preferredHeight: menu.entryHeight

                onClicked: {
                    GpuScreenRecord.saveReplay();
                    root.showMenu = false;
                }

                RowLayout {
                    spacing: 8

                    anchors {
                        fill: parent
                        margins: 4
                    }

                    IconImage {
                        source: Quickshell.iconPath("document-save")
                        implicitWidth: 24
                        implicitHeight: 24
                    }

                    StyledText {
                        color: ShellSettings.colors.active.windowText
                        text: "Save Replay"
                        Layout.fillWidth: true
                    }

                    StyledText {
                        color: ShellSettings.colors.active.windowText.darker(1.25)
                        text: `${GpuScreenRecord.config.replayBufferSize}s`
                    }
                }
            }

            // Mode toggle
            StyledMouseArea {
                id: modeToggle
                color: containsMouse ? ShellSettings.colors.active.light : "transparent"
                radius: 6

                Layout.fillWidth: true
                Layout.preferredHeight: menu.entryHeight

                RowLayout {
                    spacing: 8

                    anchors {
                        fill: parent
                        margins: 4
                    }

                    IconImage {
                        source: Quickshell.iconPath(GpuScreenRecord.isReplayMode ? "media-playlist-repeat" : "camera-ready")
                        implicitWidth: 24
                        implicitHeight: 24
                    }

                    StyledText {
                        color: ShellSettings.colors.active.windowText
                        text: "Mode"
                        Layout.fillWidth: true
                    }

                    StyledText {
                        color: ShellSettings.colors.active.windowText.darker(1.25)
                        text: GpuScreenRecord.isReplayMode ? "Replay" : "Record"
                    }
                }

                onClicked: {
                    if (GpuScreenRecord.config.replayBufferSize > 0) {
                        GpuScreenRecord.config.replayBufferSize = 0;
                    } else {
                        GpuScreenRecord.config.replayBufferSize = 30;
                    }
                }
            }
        }
    }
}
