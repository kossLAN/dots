pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import Qt.labs.folderlistmodel
import ".."

ColumnLayout {
    id: container
    spacing: 5

    // anchors {
    //     fill: parent
    //     margins: 10
    // }

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

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true

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
