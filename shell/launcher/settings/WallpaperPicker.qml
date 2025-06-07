pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Qt.labs.folderlistmodel
import qs
import qs.widgets

Item {
    id: root

    property bool customPathExists: false
    property string customPath: ShellSettings.settings.wallpapersPath

    property real screenAspect: 16 / 9

    onCustomPathChanged: pathChecker.running = true

    Component.onCompleted: pathChecker.running = true

    Process {
        id: pathChecker
        command: ["test", "-d", root.customPath]

        onExited: (exitCode, exitStatus) => {
            root.customPathExists = (exitCode === 0);
            root.updateCombinedModel();
        }
    }

    FolderListModel {
        id: builtinFolder
        folder: Qt.resolvedUrl("root:resources/wallpapers")
        nameFilters: ["*.jpg", "*.png", "*.jpeg", "*.webp"]
    }

    FolderListModel {
        id: customFolder
        folder: root.customPathExists ? "file://" + root.customPath : ""
        nameFilters: ["*.jpg", "*.png", "*.jpeg", "*.webp"]
    }

    ListModel {
        id: combinedModel
    }

    function updateCombinedModel() {
        combinedModel.clear();

        for (let i = 0; i < builtinFolder.count; i++) {
            combinedModel.append({
                fileUrl: builtinFolder.get(i, "fileUrl")
            });
        }

        if (root.customPathExists) {
            for (let i = 0; i < customFolder.count; i++) {
                combinedModel.append({
                    fileUrl: customFolder.get(i, "fileUrl")
                });
            }
        }
    }

    Connections {
        target: builtinFolder

        function onCountChanged() {
            root.updateCombinedModel();
        }
    }

    Connections {
        target: customFolder

        function onCountChanged() {
            root.updateCombinedModel();
        }
    }

    ColumnLayout {
        spacing: 12

        anchors {
            fill: parent
            margins: 8
        }

        Item {
            id: previewContainer
            Layout.fillWidth: true
            Layout.preferredHeight: 225

            property real maxWidth: width * 0.9
            property real maxHeight: height * 0.9
            property real scaledWidth: Math.min(maxWidth, maxHeight * root.screenAspect)
            property real scaledHeight: scaledWidth / root.screenAspect

            ClippingRectangle {
                radius: 12
                width: previewContainer.scaledWidth
                height: previewContainer.scaledHeight
                anchors.centerIn: parent

                Image {
                    source: ShellSettings.settings.wallpaperUrl
                    fillMode: Image.PreserveAspectCrop
                    anchors.fill: parent
                }
            }
        }

        StyledRectangle {
            color: ShellSettings.colors.active.base

            Layout.fillWidth: true
            Layout.fillHeight: true

            GridView {
                id: wallpaperGrid
                cellWidth: 150
                cellHeight: 150
                clip: true

                anchors.centerIn: parent
                width: Math.floor(parent.width / cellWidth) * cellWidth
                height: parent.height

                model: combinedModel

                delegate: Item {
                    id: cell
                    required property var fileUrl

                    width: wallpaperGrid.cellWidth
                    height: wallpaperGrid.cellHeight

                    ClippingRectangle {
                        radius: 8

                        anchors {
                            fill: parent
                            margins: 6
                        }

                        Rectangle {
                            visible: mouseArea.containsMouse || cell.fileUrl === ShellSettings.settings.wallpaperUrl
                            color: "transparent"
                            radius: 8
                            z: 1

                            anchors.fill: parent

                            border {
                                width: 2

                                color: {
                                    if (cell.fileUrl === ShellSettings.settings.wallpaperUrl)
                                        return ShellSettings.colors.active.highlight;
                                    else
                                        return ShellSettings.colors.active.windowText;
                                }
                            }
                        }

                        Image {
                            source: cell.fileUrl
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            anchors.fill: parent

                            sourceSize {
                                height: 150
                                width: 150
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: ShellSettings.settings.wallpaperUrl = cell.fileUrl
                        }
                    }
                }
            }
        }
    }
}
