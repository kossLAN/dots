pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Widgets

import qs
import qs.widgets

ColumnLayout {
    id: root

    required property var picker

    spacing: 4

    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        StyledDropdown {
            Layout.preferredWidth: 130
            Layout.preferredHeight: 28
            color: ShellSettings.colors.active.mid

            model: [
                {
                    label: "Name",
                    value: "0"
                },
                {
                    label: "Date Modified",
                    value: "1"
                },
                {
                    label: "Size",
                    value: "2"
                },
                {
                    label: "Type",
                    value: "3"
                },
            ]

            currentValue: root.picker._sortField.toString()
            onSelected: value => root.picker._sortField = parseInt(value)
        }

        IconButton {
            implicitSize: 24
            source: Quickshell.iconPath(root.picker._sortReversed ? "view-sort-descending" : "view-sort-ascending")
            onClicked: root.picker._sortReversed = !root.picker._sortReversed
        }

        Item {
            Layout.fillWidth: true
        }

        StyledDropdown {
            visible: root.picker._parsedFilters.length > 1
            color: ShellSettings.colors.active.mid
            Layout.preferredWidth: 140
            Layout.preferredHeight: 28

            model: {
                const items = [];

                for (let i = 0; i < root.picker._parsedFilters.length; i++) {
                    items.push({
                        label: root.picker._parsedFilters[i].label,
                        value: i.toString()
                    });
                }

                return items;
            }

            currentValue: root.picker._activeFilterIndex.toString()
            onSelected: value => root.picker._activeFilterIndex = parseInt(value)
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        ClippingRectangle {
            anchors.fill: parent
            radius: 8
            color: ShellSettings.colors.active.base

            FolderListModel {
                id: folderModel

                folder: root.picker.currentFolder
                showDirs: true
                showFiles: !root.picker.folderMode
                showHidden: root.picker.showHidden
                showDirsFirst: true
                showDotAndDotDot: false
                caseSensitive: false
                sortReversed: root.picker._sortReversed

                sortField: {
                    switch (root.picker._sortField) {
                    case 1:
                        return FolderListModel.Time;
                    case 2:
                        return FolderListModel.Size;
                    case 3:
                        return FolderListModel.Type;
                    default:
                        return FolderListModel.Name;
                    }
                }

                nameFilters: {
                    const patterns = root.picker._activePatterns;

                    if (!patterns || patterns.length === 0)
                        return [];

                    if (patterns.length === 1 && patterns[0] === "*")
                        return [];

                    return patterns;
                }
            }

            ListView {
                id: fileList

                anchors.fill: parent
                model: folderModel
                spacing: 0
                clip: true

                StyledText {
                    anchors.centerIn: parent
                    text: "Empty folder"
                    visible: fileList.count === 0
                    opacity: 0.5
                }

                delegate: FilePickerEntry {
                    width: fileList.width
                    sizeText: !fileIsDir && !root.picker.folderMode ? root.picker._formatSize(fileSize) : ""
                    selected: root.picker._selectedPath === filePath

                    onEntryClicked: {
                        root.picker._selectedPath = filePath;
                        root.picker._selectedName = fileName;
                        root.picker._selectedIsDir = fileIsDir;
                    }

                    onEntryDoubleClicked: {
                        if (fileIsDir) {
                            root.picker._navigateTo(`file://${filePath}`);
                        } else {
                            root.picker._selectedPath = filePath;
                            root.picker._selectedName = fileName;
                            root.picker._selectedIsDir = false;
                            root.picker._accept();
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded

                    contentItem: Rectangle {
                        implicitWidth: 8
                        radius: 4
                        color: ShellSettings.colors.active.light
                        opacity: parent.active ? 0.8 : 0.0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: "transparent"
            border.width: 1
            border.color: ShellSettings.colors.active.light
        }
    }
}
