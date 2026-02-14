import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray

import qs

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

        let items = ShellSettings.settings.pinnedTray ?? [];
        const fromIndex = items.indexOf(trayId);

        if (fromIndex === -1 || fromIndex === toIndex)
            return;

        items = items.filter(id => id !== trayId);

        const adjustedIndex = fromIndex < toIndex ? toIndex - 1 : toIndex;
        items.splice(adjustedIndex, 0, trayId);

        ShellSettings.settings.pinnedTray = items;
    }

    // Dynamic system tray items
    Instantiator {
        model: SystemTray.items

        delegate: SysTrayItem {
            required property SystemTrayItem modelData
            item: modelData
        }

        onObjectAdded: function (index, object) {
            root.sysTrayItems = root.sysTrayItems.concat([object]);
        }

        onObjectRemoved: function (index, object) {
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

        // Drop target when no pinned items exist
        Item {
            visible: root.draggedItem !== null && root.pinnedModel.length === 0

            Layout.preferredWidth: height
            Layout.fillHeight: true

            DropArea {
                anchors.fill: parent
                keys: ["tray-item"]

                Rectangle {
                    width: 2
                    color: ShellSettings.colors.active.highlight
                    visible: parent.containsDrag

                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                }

                onDropped: drop => {
                    root.pinItem(drop.text, 0);
                    root.draggedItem = null;
                }
            }
        }

        Repeater {
            id: pinnedRepeater
            model: root.pinnedModel

            delegate: Item {
                id: delegate

                required property TrayBacker modelData
                required property int index

                property Item rootRef: root

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
                        width: 2
                        color: ShellSettings.colors.active.highlight
                        visible: dropArea.containsDrag

                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }
                    }

                    onDropped: drop => {
                        const trayId = drop.text;
                        const isPinned = (ShellSettings.settings.pinnedTray ?? []).includes(trayId);

                        if (isPinned) {
                            delegate.rootRef.moveItem(trayId, delegate.index);
                        } else {
                            delegate.rootRef.pinItem(trayId, delegate.index);
                        }

                        delegate.rootRef.draggedItem = null;
                    }
                }

                Loader {
                    id: iconLoader
                    sourceComponent: delegate.modelData.button
                    anchors.fill: parent

                    Drag.dragType: Drag.Automatic
                    Drag.supportedActions: Qt.MoveAction
                    Drag.imageSource: delegate.modelData.icon
                    Drag.imageSourceSize: Qt.size(20, 20)
                    Drag.active: dragHandler.active
                    Drag.mimeData: {
                        "text/plain": delegate.modelData.trayId,
                        "tray-item": "true"
                    }

                    Drag.onDragStarted: {
                        delegate.rootRef.draggedItem = delegate.modelData;
                    }

                    Drag.onDragFinished: {
                        delegate.rootRef.draggedItem = null;
                    }

                    DragHandler {
                        id: dragHandler
                        target: null
                    }
                }

                property PopupItem menu: PopupItem {
                    owner: delegate
                    popup: delegate.rootRef.bar.popup
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
                            if (delegate.rootRef.draggedItem !== delegate.modelData) {
                                delegate.showMenu = !delegate.showMenu;
                            }
                        }
                    }
                }
            }
        }
    }
}
