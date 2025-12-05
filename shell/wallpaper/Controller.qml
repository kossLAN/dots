import Quickshell
import QtQuick
import qs

Scope {
    id: root

    LazyLoader {
        loading: true

        Scope {
            Variants {
                model: Quickshell.screens

                PanelWindow {
                    required property var modelData
                    color: "black"
                    aboveWindows: false
                    screen: modelData

                    anchors {
                        left: true
                        right: true
                        top: true
                        bottom: true
                    }

                    Image {
                        source: ShellSettings.settings.wallpaperUrl
                        fillMode: Image.PreserveAspectCrop
                        anchors.fill: parent
                    }
                }
            }

            Connections {
                target: ShellSettings.settings

                function onWallpaperUrlChanged() {
                    console.log("Switching wallpaper: " + ShellSettings.settings.wallpaperUrl);
                }
            }
        }
    }
}
