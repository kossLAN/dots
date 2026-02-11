pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import qs.widgets
import qs.launcher.settings
import qs.launcher.chat

Singleton {
    property alias launcherOpen: persist.launcherOpen

    PersistentProperties {
        id: persist
        property bool launcherOpen: false
    }

    IpcHandler {
        target: "launcher"

        function open(): void {
            persist.launcherOpen = true;
        }

        function close(): void {
            persist.launcherOpen = false;
        }

        function toggle(): void {
            persist.launcherOpen = !persist.launcherOpen;
        }
    }

    LazyLoader {
        active: persist.launcherOpen

        PanelWindow {
            id: panel
            visible: true
            color: "transparent"
            exclusiveZone: 0

            WlrLayershell.namespace: "shell:launcher"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            mask: Region {
                item: view
            }

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            RectangularShadow {
                anchors.fill: view
                radius: view.radius
                blur: 16
                spread: 2
                offset: Qt.vector2d(0, 4)
                color: Qt.rgba(0, 0, 0, 0.5)
            }

            StyledRectangle {
                id: view
                clip: true
                implicitWidth: manager.implicitWidth
                implicitHeight: manager.implicitHeight

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: (panel.screen.height / 2) - 325
                }

                LauncherManager {
                    id: manager

                    model: [
                        ApplicationLauncher {
                            onAccepted: persist.launcherOpen = false
                        },
                        Settings {},
                        Chat {}
                    ]
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        persist.launcherOpen = false;
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Tab) {
                        manager.currentIndex = (manager.currentIndex + 1) % manager.enabledModel.length;
                        event.accepted = true;
                    }
                }

                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on implicitHeight {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }

    function init() {
    }
}
