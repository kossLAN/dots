import Quickshell
import Quickshell.Io
import QtQuick
import ".."

Scope {
    id: root
    required property var screen
    property string matugenConf: Qt.resolvedUrl("matugen.toml").toString().replace("file://", "")

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
                    matugen.running = true;
                }

                function onColorSchemeChanged() {
                    console.log("Switching color scheme: " + ShellSettings.settings.colorScheme);
                    matugen.running = true;
                }
            }

            Process {
                id: matugen
                running: false

                // Formatter is keeping me hostage frfr...
                command: ["matugen", "image", ShellSettings.settings.wallpaperUrl.replace("file://", ""), "--type", ShellSettings.settings.colorScheme, "--json", "hex", "--config", root.matugenConf]

                stdout: SplitParser {
                    onRead: data => {
                        console.log(ShellSettings.settings.colorScheme);
                        try {
                            ShellSettings.colors = JSON.parse(data)['colors']['dark'];
                        } catch (e) {}
                    }
                }

                stderr: SplitParser {
                    onRead: data => console.log(`line read: ${data}`)
                }
            }
        }
    }
}
