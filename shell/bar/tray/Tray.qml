import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

import qs
import qs.widgets

import qs.bar
import qs.bar.tray
import qs.bar.tray.power
import qs.bar.tray.volume
import qs.bar.tray.systray
import qs.bar.tray.bluetooth
import qs.bar.tray.wifi
import qs.bar.tray.gsr

Rectangle {
    id: root
    color: "transparent"

    required property var bar

    property list<TrayBacker> staticModel: [
        GsrMenu {},
        BluetoothMenu {},
        WifiMenu {},
        PowerMenu {},
        VolumeIndicator {}
    ]

    property list<TrayBacker> sysTrayItems: []

    property list<TrayBacker> model: staticModel.concat(sysTrayItems)

    property list<TrayBacker> enabledModel: model.filter(x => x.enabled)

    property list<TrayBacker> pinnedModel: {
        const order = ShellSettings.settings.pinnedTray ?? [];

        return enabledModel.filter(x => order.includes(x.trayId)).sort((a, b) => {
            const aIndex = order.indexOf(a.trayId);
            const bIndex = order.indexOf(b.trayId);
            return aIndex - bIndex;
        });
    }
    property list<TrayBacker> unpinnedModel: {
        const order = ShellSettings.settings.pinnedTray ?? [];
        return enabledModel.filter(x => !order.includes(x.trayId));
    }

    // Track currently dragged item
    property TrayBacker draggedItem: null

    function pinItem(trayId: string, atIndex: int) {
        draggedItem = null;
        let items = (ShellSettings.settings.pinnedTray ?? []).filter(id => id !== trayId);
        if (atIndex < 0 || atIndex >= items.length) {
            items.push(trayId);
        } else {
            items.splice(atIndex, 0, trayId);
        }
        ShellSettings.settings.pinnedTray = items;
    }

    function unpinItem(trayId: string) {
        draggedItem = null;
        ShellSettings.settings.pinnedTray = (ShellSettings.settings.pinnedTray ?? []).filter(id => id !== trayId);
    }

    function moveItem(trayId: string, toIndex: int) {
        draggedItem = null;
        let items = (ShellSettings.settings.pinnedTray ?? []).filter(id => id !== trayId);
        items.splice(toIndex, 0, trayId);
        ShellSettings.settings.pinnedTray = items;
    }

    // Dynamic system tray items
    Instantiator {
        model: SystemTray.items

        delegate: SysTrayItem {
            required property SystemTrayItem modelData
            item: modelData
        }

        onObjectAdded: (index, object) => {
            root.sysTrayItems = root.sysTrayItems.concat([object]);
        }

        onObjectRemoved: (index, object) => {
            root.sysTrayItems = root.sysTrayItems.filter(x => x !== object);
        }
    }

    implicitWidth: container.implicitWidth

    RowLayout {
        id: container
        anchors.fill: parent
        spacing: 4

        UnpinnedTray {
            bar: root.bar
            model: root.unpinnedModel
            tray: root

            Layout.preferredWidth: height
            Layout.fillHeight: true
        }

        Repeater {
            id: pinnedRepeater
            model: root.pinnedModel

            delegate: Item {
                id: delegate

                required property TrayBacker modelData
                required property int index

                property bool showMenu: false

                Layout.preferredWidth: height
                Layout.fillHeight: true

                // Drop area for reordering
                DropArea {
                    id: dropArea
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width / 2
                    z: 1

                    keys: ["tray-item"]

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 2
                        color: ShellSettings.colors.active.highlight
                        visible: dropArea.containsDrag
                    }

                    onDropped: drop => {
                        if (root.draggedItem && root.draggedItem.trayId !== delegate.modelData.trayId) {
                            root.moveItem(root.draggedItem.trayId, delegate.index);
                        }

                        root.draggedItem = null;
                    }
                }

                // Drop area for right side of last item
                DropArea {
                    id: dropAreaRight
                    width: parent.width / 2
                    z: 1
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    keys: ["tray-item"]
                    visible: delegate.index === root.pinnedModel.length - 1

                    Rectangle {
                        visible: dropAreaRight.containsDrag
                        color: ShellSettings.colors.active.highlight
                        width: 2
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                    }

                    onDropped: drop => {
                        if (root.draggedItem) {
                            root.moveItem(root.draggedItem.trayId, delegate.index + 1);
                        }

                        root.draggedItem = null;
                    }
                }

                Loader {
                    id: iconLoader
                    active: delegate.modelData.icon
                    sourceComponent: delegate.modelData.icon
                    opacity: root.draggedItem === delegate.modelData ? 0.5 : 1
                    anchors.fill: parent
                }

                MouseArea {
                    id: mouseArea
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    drag.target: dragItem
                    drag.axis: Drag.XAndYAxis
                    drag.threshold: 5

                    onClicked: {
                        delegate.modelData.clicked();
                    }

                    onPressedChanged: {
                        if (!pressed) {
                            if (root.draggedItem === delegate.modelData) {
                                dragItem.Drag.drop();
                                root.draggedItem = null;
                            }

                            dragItem.x = 0;
                            dragItem.y = 0;
                        }
                    }
                }

                // Draggable visual
                Item {
                    id: dragItem
                    width: delegate.width
                    height: delegate.height
                    visible: root.draggedItem === delegate.modelData

                    Drag.active: root.draggedItem === delegate.modelData
                    Drag.keys: ["tray-item"]
                    Drag.hotSpot.x: width / 2
                    Drag.hotSpot.y: height / 2

                    onXChanged: {
                        if (mouseArea.pressed && mouseArea.drag.active && root.draggedItem === null) {
                            root.draggedItem = delegate.modelData;
                        }
                    }

                    Item {
                        opacity: 0.55
                        anchors.fill: parent

                        Loader {
                            active: delegate.modelData.icon
                            sourceComponent: delegate.modelData.icon
                            anchors.fill: parent
                            anchors.margins: 2
                        }
                    }
                }

                property PopupItem menu: PopupItem {
                    owner: delegate
                    popup: root.bar.popup
                    show: delegate.showMenu
                    onClosed: delegate.showMenu = false

                    implicitWidth: menuLoader.implicitWidth
                    implicitHeight: menuLoader.implicitHeight

                    Loader {
                        id: menuLoader
                        active: delegate.modelData.menu
                        sourceComponent: delegate.modelData.menu
                        anchors.fill: parent
                    }

                    Connections {
                        target: delegate.modelData

                        function onClicked() {
                            if (!delegate.isDragging) {
                                delegate.showMenu = !delegate.showMenu;
                            }
                        }
                    }
                }
            }
        }
    }
}
