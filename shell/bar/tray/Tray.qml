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

        onObjectAdded: function(index, object) {
            root.sysTrayItems = root.sysTrayItems.concat([object]);
        }

        onObjectRemoved: function(index, object) {
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
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 2
                        color: ShellSettings.colors.active.highlight
                        visible: dropArea.containsDrag
                    }

                    onDropped: function(drop) {
                        if (delegate.rootRef.draggedItem && delegate.rootRef.draggedItem.trayId !== delegate.modelData.trayId) {
                            delegate.rootRef.moveItem(delegate.rootRef.draggedItem.trayId, delegate.index);
                        }

                        delegate.rootRef.draggedItem = null;
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
                    visible: delegate.index === delegate.rootRef.pinnedModel.length - 1

                    Rectangle {
                        visible: dropAreaRight.containsDrag
                        color: ShellSettings.colors.active.highlight
                        width: 2
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                    }

                    onDropped: function(drop) {
                        if (delegate.rootRef.draggedItem) {
                            delegate.rootRef.moveItem(delegate.rootRef.draggedItem.trayId, delegate.index + 1);
                        }

                        delegate.rootRef.draggedItem = null;
                    }
                }

                Loader {
                    id: iconLoader
                    active: delegate.modelData.icon
                    sourceComponent: delegate.modelData.icon
                    opacity: delegate.rootRef.draggedItem === delegate.modelData ? 0.5 : 1
                    anchors.fill: parent
                }

                TrayItemDrag {
                    modelData: delegate.modelData
                    rootRef: delegate.rootRef
                    dragKey: "tray-item"

                    onClicked: delegate.modelData.clicked()

                    onDragComplete: function(action, item) {
                        delegate.rootRef.moveItem(item.trayId, delegate.index);
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
