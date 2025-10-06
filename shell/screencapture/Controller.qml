pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

Singleton {
    id: root

    property bool windowOpen: false

    IpcHandler {
        target: "screencapture"

        function screenshot(): void {
            root.windowOpen = true;
        }
    }

    LazyLoader {
        active: root.windowOpen

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

                SelectionRectangle {
                    id: selection
                    anchors.fill: parent

                    onAreaSelected: selection => {
                        let screen = focusedScreen.screen;
                        const x = Math.floor(selection.x) + screen.x;
                        const y = Math.floor(selection.y) + screen.y;
                        const width = Math.floor(selection.width);
                        const height = Math.floor(selection.height);

                        let position = `${x},${y} ${width}x${height}`;
                        let path = "/home/koss/Pictures/screenshot.png";

                        Quickshell.execDetached({
                            command: ["grim", "-g", position, path]
                        });

                        root.windowOpen = false;
                    }
                }
            }
        }
    }

    function init() {
    }
}
