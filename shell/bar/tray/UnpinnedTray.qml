pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import qs
import qs.widgets
import qs.bar

Item {
    id: root

    required property var bar
    required property var tray
    required property list<TrayBacker> model

    property bool showMenu: false
    property TrayBacker selectedTray: null

    onModelChanged: {
        if (model.length === 0) {
            showMenu = false;
            selectedTray = null;
        }
    }

    // Drop area to unpin items
    DropArea {
        id: unpinDropArea
        anchors.fill: parent
        keys: ["tray-item"]

        onDropped: (drop) => {
            if (root.tray.draggedItem) {
                root.tray.unpinItem(root.tray.draggedItem.trayId);
            }

            root.tray.draggedItem = null;
        }
    }

    StyledMouseArea {
        id: trigger
        anchors.fill: parent
        visible: !unpinDropArea.containsDrag
        enabled: root.model.length > 0
        onClicked: {
            if (root.selectedTray) {
                // If there's an active tray menu, go back to grid
                root.selectedTray = null;
            } else {
                // If showing grid or closed, toggle menu
                root.showMenu = !root.showMenu;
            }
        }

        IconImage {
            anchors.fill: parent
            anchors.margins: 4
            source: Quickshell.iconPath("arrow-down")
            opacity: root.model.length === 0 ? 0.3 : 1
        }
    }

    IconImage {
        anchors.fill: parent
        anchors.margins: 4
        source: Quickshell.iconPath("arrow-down")
        opacity: 0.5
        visible: unpinDropArea.containsDrag
    }

    property PopupItem menu: PopupItem {
        owner: root
        popup: root.bar.popup
        show: root.showMenu
        onClosed: {
            root.showMenu = false;
            root.selectedTray = null;
        }

        implicitWidth: contentLoader.implicitWidth
        implicitHeight: contentLoader.implicitHeight

        Loader {
            id: contentLoader
            anchors.fill: parent
            sourceComponent: root.selectedTray ? trayMenuComponent : gridComponent

            onSourceComponentChanged: opacityAnim.restart()

            NumberAnimation {
                id: opacityAnim
                target: contentLoader
                property: "opacity"
                from: 0
                to: 1
                duration: 200
                easing.type: Easing.InCubic
            }
        }

        Component {
            id: gridComponent

            Item {
                id: gridContainer

                property real iconSize: ShellSettings.sizing.barHeight
                property real gridSpacing: 4
                property real gridMargins: 4
                property int columns: 4

                implicitWidth: grid.implicitWidth + (2 * gridMargins)
                implicitHeight: grid.implicitHeight + (2 * gridMargins)

                // Drop area for pinning items from this popup
                DropArea {
                    id: gridDropArea
                    anchors.fill: parent
                    keys: ["tray-item"]

                    Rectangle {
                        anchors.fill: parent
                        color: ShellSettings.colors.active.highlight
                        opacity: gridDropArea.containsDrag ? 0.2 : 0
                        radius: 4
                    }

                    onDropped: (drop) => {
                        if (root.tray.draggedItem) {
                            root.tray.unpinItem(root.tray.draggedItem.trayId);
                        }
                        root.tray.draggedItem = null;
                    }
                }

                GridLayout {
                    id: grid
                    columns: gridContainer.columns
                    rowSpacing: gridContainer.gridSpacing
                    columnSpacing: gridContainer.gridSpacing

                    anchors {
                        centerIn: parent
                    }

                    Repeater {
                        model: root.model

                        delegate: Item {
                            id: gridDelegate

                            required property TrayBacker modelData
                            required property int index

                            readonly property bool isDragging: root.tray.draggedItem === modelData

                            Layout.preferredWidth: gridContainer.iconSize
                            Layout.preferredHeight: gridContainer.iconSize

                            Loader {
                                id: gridIconLoader
                                anchors.fill: parent
                                sourceComponent: gridDelegate.modelData.icon
                                opacity: gridDelegate.isDragging ? 0.5 : 1
                            }

                            MouseArea {
                                id: gridMouseArea
                                anchors.fill: parent
                                drag.target: gridDragItem
                                drag.axis: Drag.XAndYAxis
                                drag.threshold: 5

                                onClicked: {
                                    root.selectedTray = gridDelegate.modelData;
                                }

                                onPressedChanged: {
                                    if (!pressed) {
                                        if (gridDelegate.isDragging) {
                                            root.tray.pinItem(gridDelegate.modelData.trayId, -1);
                                        }

                                        gridDragItem.x = 0;
                                        gridDragItem.y = 0;
                                    }
                                }
                            }

                            // Draggable visual for unpinned items
                            Item {
                                id: gridDragItem
                                width: gridDelegate.width
                                height: gridDelegate.height
                                visible: gridDelegate.isDragging

                                Drag.active: gridDelegate.isDragging
                                Drag.keys: ["tray-item-unpin"]
                                Drag.hotSpot.x: width / 2
                                Drag.hotSpot.y: height / 2

                                onXChanged: {
                                    if (gridMouseArea.pressed && gridMouseArea.drag.active && root.tray.draggedItem === null) {
                                        root.tray.draggedItem = gridDelegate.modelData;
                                    }
                                }

                                Item {
                                    opacity: 0.5
                                    anchors.fill: parent

                                    Loader {
                                        active: gridDelegate.modelData.icon
                                        sourceComponent: gridDelegate.modelData.icon
                                        anchors.fill: parent
                                        anchors.margins: 2
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Component {
            id: trayMenuComponent

            Loader {
                sourceComponent: root.selectedTray?.menu ?? null
            }
        }
    }
}
