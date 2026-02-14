pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Qt.labs.folderlistmodel
import Quickshell.Widgets

import qs
import qs.widgets

SettingsBacker {
    icon: "preferences-desktop-wallpaper"

    summary: "Wallpaper Settings"

    content: Item {
        ColumnLayout {
            spacing: 4

            anchors {
                fill: parent
                margins: 8
            }

            Item {
                Layout.preferredWidth: 160 * 2.3
                Layout.preferredHeight: 90 * 2.3
                Layout.alignment: Qt.AlignCenter
                Layout.topMargin: 40

                RectangularShadow {
                    anchors.fill: preview
                    radius: preview.radius
                    blur: 16
                    spread: 2
                    color: Qt.rgba(0, 0, 0, 0.5)
                }

                ClippingRectangle {
                    id: preview
                    radius: 12
                    anchors.fill: parent

                    Image {
                        source: ShellSettings.settings.wallpaperUrl
                        anchors.fill: parent
                    }
                }
            }

            StyledRectangle {
                color: ShellSettings.colors.active.base
                radius: 8

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 40

                GridView {
                    id: wallpaperGrid
                    clip: true
                    cellWidth: width / 6
                    cellHeight: cellWidth

                    anchors {
                        fill: parent
                        margins: 8
                    }

                    model: FolderListModel {
                        id: builtinFolder
                        folder: `file://${ShellSettings.settings.wallpapersPath}`
                        nameFilters: ["*.jpg", "*.png", "*.jpeg", "*.webp"]
                    }

                    delegate: MouseArea {
                        id: wallpaper

                        required property string fileName
                        required property url filePath

                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        implicitWidth: wallpaperGrid.cellWidth
                        implicitHeight: wallpaperGrid.cellHeight

                        onClicked: {
                            ShellSettings.settings.wallpaperUrl = wallpaper.filePath;
                        }

                        ClippingRectangle {
                            color: ShellSettings.colors.active.base
                            radius: 4

                            anchors {
                                fill: parent
                                margins: 4
                            }

                            Image {
                                source: wallpaper.filePath
                                fillMode: Image.PreserveAspectCrop
                                anchors.fill: parent
                            }

                            Rectangle {
                                visible: wallpaper.containsMouse
                                color: "white"
                                opacity: 0.1
                                anchors.fill: parent
                            }
                        }
                    }
                }
            }
        }
    }
}
