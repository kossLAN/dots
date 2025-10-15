pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs

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

                        // i hate javascript
                        let date = new Date();
                        let year = date.getFullYear();
                        let month = date.getMonth();
                        let day = date.getDay();
                        let dateString = `${year}-${month}-${day}`;

                        let hour = date.getHours();
                        let minutes = date.getMinutes();
                        let seconds = date.getSeconds();
                        let timeString = `${hour}:${minutes}:${seconds}`;

                        let fileName = `screenshot-${dateString}-${timeString}.png`
                        const path = `${ShellSettings.settings.screenshotPath}/${fileName}`;

                        console.log(`Screenshot saved to ${path}`);

                        // take a screenshot with grim, probably a better way to get this path...
                        let scriptUrl = Qt.resolvedUrl("root:scripts/screenshot.sh").toLocaleString();
                        let scriptPath = scriptUrl.replace(/^(file:\/{2})/, "");

                        Quickshell.execDetached({
                            command: ["sh", scriptPath, position, path]
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
