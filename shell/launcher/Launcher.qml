pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs
import qs.launcher.settings

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
            color: "transparent"
            exclusiveZone: 0

            WlrLayershell.namespace: "shell:launcher"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            RectangularShadow {
                anchors.fill: content
                radius: content.radius
                blur: 16
                spread: 2
                offset: Qt.vector2d(0, 4)
                color: Qt.rgba(0, 0, 0, 0.5)
            }

            Rectangle {
                id: content
                clip: true
                radius: 12
                color: ShellSettings.colors.active.window

                property int currentIndex: 0
                property int displayedIndex: 0

                readonly property var pages: [appLauncher, settings]
                readonly property var currentPage: pages[displayedIndex]

                implicitWidth: currentPage.implicitWidth
                implicitHeight: currentPage.implicitHeight

                border {
                    width: 1
                    color: ShellSettings.colors.active.light
                }

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: (panel.screen.height / 2) - 325
                }

                Item {
                    id: pageContainer
                    anchors.fill: parent
                    opacity: content.currentIndex === content.displayedIndex ? 1 : 0

                    onOpacityChanged: {
                        if (opacity === 0 && content.currentIndex !== content.displayedIndex) {
                            content.displayedIndex = content.currentIndex;
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.OutCubic
                        }
                    }

                    ApplicationLauncher {
                        id: appLauncher
                        visible: content.displayedIndex === 0
                        onAccepted: persist.launcherOpen = false
                    }

                    Settings {
                        id: settings
                        visible: content.displayedIndex === 1
                    }
                }

                Switcher {
                    id: switcher
                    model: ["search", "settings"]
                    currentIndex: content.currentIndex
                    height: 28
                    parent: content.displayedIndex === 0 ? appLauncher.switcherParent : settings.switcherParent

                    onClicked: index => content.currentIndex = index
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        persist.launcherOpen = false;
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Tab) {
                        content.currentIndex = (content.currentIndex + 1) % 2;
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
