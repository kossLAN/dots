pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import qs
import qs.widgets
import qs.bar
import qs.bar.tray

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
        keys: ["tray-item"]
        anchors.fill: parent

        onDropped: drop => {
            root.tray.unpinItem(drop.text);
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
                root.selectedTray = null;
            } else {
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

                // Drop area for pinning items to the popup
                DropArea {
                    id: gridDropArea
                    anchors.fill: parent
                    keys: ["tray-item"]

                    onDropped: drop => {
                        root.tray.unpinItem(drop.text);
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
                                sourceComponent: gridDelegate.modelData.button
                            }

                            Connections {
                                target: gridDelegate.modelData

                                function onClicked() {
                                    if (root.tray.draggedItem !== gridDelegate.modelData) {
                                        root.selectedTray = gridDelegate.modelData;
                                    }
                                }
                            }

                            Drag.dragType: Drag.Automatic
                            Drag.supportedActions: Qt.MoveAction
                            Drag.imageSource: modelData.icon
                            Drag.imageSourceSize: Qt.size(20, 20)
                            Drag.active: dragHandler.active
                            Drag.mimeData: {
                                "text/plain": gridDelegate.modelData.trayId,
                                "tray-item": "true"
                            }

                            DragHandler {
                                id: dragHandler
                                target: null 
                                onActiveChanged: {
                                    parent.Drag.active = active

                                    if (active) {
                                        root.tray.draggedItem = gridDelegate.modelData
                                    } else {
                                        root.tray.draggedItem = null
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
