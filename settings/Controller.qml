pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Qt.labs.folderlistmodel
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
                id: container
                spacing: 5

                anchors {
                    fill: parent
                    margins: 10
                }

                ClippingRectangle {
                    radius: 20
                    Layout.preferredWidth: 464
                    Layout.preferredHeight: 261
                    Layout.alignment: Qt.AlignCenter
                    Layout.margins: 20

                    Image {
                        id: wallpaperImage
                        source: ShellSettings.settings.wallpaperUrl
                        fillMode: Image.PreserveAspectFit

                        anchors {
                            fill: parent
                        }
                    }
                }

                Rectangle {
                    color: ShellSettings.colors["surface_container"]
                    radius: 20
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors.fill: parent

                        ListView {
                            id: horizontalList
                            orientation: ListView.Horizontal
                            model: ["scheme-content", "scheme-expressive", "scheme-fidelity", "scheme-fruit-salad", "scheme-monochrome", "scheme-neutral", "scheme-rainbow", "scheme-tonal-spot", "scheme-vibrant"]
                            spacing: 10
                            clip: true

                            Layout.fillWidth: true
                            Layout.preferredHeight: 100
                            Layout.margins: 10

                            delegate: Rectangle {
                                id: paletteCell
                                required property string modelData
                                property string matugenConf: Qt.resolvedUrl("root:wallpaper/matugen.toml").toString().replace("file://", "")
                                property var colors: {
                                    "primary": "white",
                                    "secondary": "gray",
                                    "tertiary": "lightgrey",
                                    "container": "black"
                                }

                                width: 100
                                height: 100
                                color: paletteSelect.containsMouse ? ShellSettings.colors["surface_container_highest"] : ShellSettings.colors["surface_container_high"]
                                radius: 20

                                MouseArea {
                                    id: paletteSelect
                                    hoverEnabled: true
                                    anchors.fill: parent
                                    onPressed: {
                                        ShellSettings.settings.colorScheme = paletteCell.modelData;
                                    }
                                }

                                Item {
                                    id: paletteContainer
                                    width: 80
                                    height: 80
                                    anchors.centerIn: parent

                                    layer.enabled: true
                                    layer.effect: OpacityMask {
                                        maskSource: Rectangle {
                                            width: paletteContainer.width
                                            height: paletteContainer.height
                                            radius: 20
                                        }
                                    }

                                    Rectangle {
                                        id: topLeft
                                        color: paletteCell.colors["primary"] ?? "white"
                                        width: parent.width / 2
                                        height: parent.height / 2
                                    }

                                    Rectangle {
                                        id: topRight
                                        color: paletteCell.colors["secondary"] ?? "gray"
                                        width: parent.width / 2
                                        height: parent.height / 2
                                        anchors.left: topLeft.right
                                    }

                                    Rectangle {
                                        id: bottomLeft
                                        color: paletteCell.colors["tertiary"] ?? "lightgrey"
                                        width: parent.width / 2
                                        height: parent.height / 2
                                        anchors.top: topLeft.bottom
                                    }

                                    Rectangle {
                                        id: bottomRight
                                        color: paletteCell.colors["surface"] ?? "black"
                                        width: parent.width / 2
                                        height: parent.height / 2
                                        anchors {
                                            top: topRight.bottom
                                            left: bottomLeft.right
                                        }
                                    }
                                }

                                Connections {
                                    target: ShellSettings.settings
                                    function onWallpaperUrlChanged() {
                                        matugen.running = true;
                                    }
                                }

                                Process {
                                    id: matugen
                                    running: true
                                    command: ["matugen", "image", ShellSettings.settings.wallpaperUrl.replace("file://", ""), "--type", paletteCell.modelData, "--json", "hex", "--config", paletteCell.matugenConf, "--dry-run"]

                                    stdout: SplitParser {
                                        onRead: data => {
                                            try {
                                                paletteCell.colors = JSON.parse(data)['colors']['dark'];
                                            } catch (e) {
                                                console.error("Error parsing JSON:", e);
                                            }
                                        }
                                    }

                                    stderr: SplitParser {
                                        onRead: data => console.log(`line read: ${data}`)
                                    }
                                }
                            }
                        }

                        Rectangle {
                            color: ShellSettings.colors["surface_container_high"]
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                        }

                        GridView {
                            id: wallpaperGrid
                            cellWidth: 200
                            cellHeight: 200
                            clip: true
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 10

                            model: FolderListModel {
                                id: folderModel
                                folder: Qt.resolvedUrl("root:resources/wallpapers")
                                nameFilters: ["*.jpg", "*.png"]
                            }

                            delegate: Rectangle {
                                id: cell
                                required property var modelData
                                width: 200
                                height: 200
                                color: "transparent"

                                Item {
                                    anchors.fill: parent

                                    Rectangle {
                                        id: border
                                        visible: mouseArea.containsMouse
                                        color: "transparent"
                                        radius: 20

                                        border {
                                            color: ShellSettings.colors["primary"]
                                            width: 2
                                        }

                                        anchors {
                                            fill: parent
                                            margins: 1
                                        }
                                    }

                                    Image {
                                        id: image
                                        source: cell.modelData.fileUrl
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true

                                        sourceSize {
                                            height: image.height
                                            width: image.width
                                        }

                                        anchors {
                                            fill: parent
                                            margins: 5
                                        }

                                        layer.enabled: true
                                        layer.effect: OpacityMask {
                                            maskSource: Rectangle {
                                                width: cell.width
                                                height: cell.height
                                                radius: 20
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        ShellSettings.settings.wallpaperUrl = cell.modelData.fileUrl;
                                    }
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
