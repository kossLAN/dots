pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import qs
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

                x: manager.centerX - (view.width / 2)

                y: {
                    if (ShellSettings.sizing.launcherPosition.y === -1)
                        return (panel.screen.height / 2) - 325;

                    return ShellSettings.sizing.launcherPosition.y;
                }

                function setPositon() {
                    manager.centerX = view.x + view.width / 2;
                    ShellSettings.sizing.launcherPosition.centerX = manager.centerX;
                    ShellSettings.sizing.launcherPosition.y = view.y;
                    view.x = Qt.binding(() => manager.centerX - (view.width / 2));
                }

                Item {
                    id: dragArea
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 8
                    z: 1

                    HoverHandler {
                        cursorShape: Qt.SizeAllCursor
                    }

                    DragHandler {
                        id: handler
                        target: view

                        onActiveChanged: {
                            if (!active) {
                                view.setPositon();
                            }
                        }
                    }
                }

                LauncherManager {
                    id: manager

                    property real centerX: ShellSettings.sizing.launcherPosition.centerX === -1 ? panel.screen.width / 2 : ShellSettings.sizing.launcherPosition.centerX

                    model: [
                        ApplicationLauncher {
                            onAccepted: persist.launcherOpen = false
                        },
                        Settings {},
                        Chat {}
                    ]

                    onCurrentIndexChanged: {
                        centerX = view.x + view.width / 2;
                    }
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
                    enabled: manager.currentItem.animate

                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on implicitHeight {
                    enabled: manager.currentItem.animate

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
