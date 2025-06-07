pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../widgets/" as Widgets
import "../"

Singleton {
    PersistentProperties {
        id: persist
        property bool windowOpen: false
    }

    IpcHandler {
        target: "settings"

        function open(): void {
            persist.windowOpen = true;
        }

        function close(): void {
            persist.windowOpen = false;
        }

        function toggle(): void {
            persist.windowOpen = !persist.windowOpen;
        }
    }

    LazyLoader {
        id: loader
        activeAsync: persist.windowOpen

        FloatingWindow {
            color: ShellSettings.colors["surface"]
            implicitWidth: 840
            implicitHeight: 845

            // onWidthChanged: {
            //     console.log("height: " + height);
            //     console.log("width: " + width);
            // }

            maximumSize {
                width: 840
                height: 845
            }

            minimumSize {
                width: 840
                height: 845
            }

            onVisibleChanged: {
                if (!visible) {
                    persist.windowOpen = false;
                }
            }

            ColumnLayout {
                spacing: 20
                anchors.fill: parent

                StackLayout {
                    id: page
                    currentIndex: topBar.currentIndex
                    Layout.fillWidth: true
                    Layout.preferredHeight: currentItem ? currentItem.implicitHeight : 0

                    readonly property Item currentItem: children[currentIndex]

                    WallpaperPicker {}
                }

                Widgets.TopBar {
                    id: topBar
                    model: ["headphones", "tune"]
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                }
            }
        }
    }

    function init() {
    }
}
