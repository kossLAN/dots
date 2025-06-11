pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import ".."

Singleton {
    id: root

    property bool windowOpen: false

    IpcHandler {
        target: "screencapture"

        function screenshot(): void {
            root.windowOpen = true;
        }
    }

    // Just use this window to grab screen context
    LazyLoader {
        activeAsync: root.windowOpen

        PanelWindow {
            id: focusedScreen
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "shell:screencapture"

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Item {
                anchors.fill: parent
                focus: true
                Keys.onEscapePressed: root.windowOpen = false

                // to get a freeze frame for now
                ScreencopyView {
                    id: screenView
                    captureSource: focusedScreen.screen
                    anchors.fill: parent

                    SelectionRectangle {
                        id: selection
                        anchors.fill: parent

                        property string position
                        property bool running: false

                        onAreaSelected: selection => {
                            let screen = focusedScreen.screen;
                            const x = Math.floor(selection.x) + screen.x;
                            const y = Math.floor(selection.y) + screen.y;
                            const width = Math.floor(selection.width);
                            const height = Math.floor(selection.height);
                            position = `${x},${y} ${width}x${height}`;

                            running = true;
                        }

                        LazyLoader {
                            activeAsync: selection.running

                            Process {
                                id: grim
                                running: true

                                property var path: `${ShellSettings.settings.screenshotPath}/screenshot.png`

                                command: ["grim", "-g", selection.position, path]


                                onRunningChanged: {
                                    if (!running) {
                                        root.windowOpen = false;
                                    }
                                }

                                stderr: SplitParser {
                                    onRead: data => console.log(`line read: ${data}`)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function init() {
    }
}
