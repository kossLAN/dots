pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Bluetooth
import qs.widgets
import qs.bar
import qs

StyledMouseArea {
    id: root
    onClicked: showMenu = !showMenu

    required property var bar
    property bool showMenu: false

    IconImage {
        anchors.fill: parent
        source: {
            if (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled) {
                return "image://icon/bluetooth-online";
            } else {
                return "image://icon/bluetooth-offline";
            }
        }
    }

    property PopupItem menu: PopupItem {
        id: menu
        owner: root
        popup: root.bar.popup
        show: root.showMenu
        onClosed: root.showMenu = false
        implicitWidth: 300
        implicitHeight: container.implicitHeight + (2 * container.anchors.margins)

        property var entryHeight: 35

        ColumnLayout {
            id: container
            spacing: 2

            anchors {
                fill: parent
                margins: 4
            }

            // Adapter
            RowLayout {
                spacing: 2
                Layout.fillWidth: true
                Layout.preferredHeight: menu.entryHeight

                IconImage {
                    Layout.preferredWidth: this.height
                    Layout.fillHeight: true
                    // Layout.margins: 5

                    source: {
                        if (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled) {
                            return "image://icon/bluetooth-online";
                        } else {
                            return "image://icon/bluetooth-offline";
                        }
                    }
                }

                ColumnLayout {
                    spacing: 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter

                    StyledText {
                        text: Bluetooth.defaultAdapter ? `Bluetooth(${Bluetooth.defaultAdapter.adapterId})` : "Bluetooth (No Adapter)"
                        color: ShellSettings.colors.active
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        Layout.preferredHeight: contentHeight
                    }

                    StyledText {
                        text: Bluetooth.defaultAdapter ? (Bluetooth.defaultAdapter.enabled ? "Enabled" : "Disabled") : "Not Available"
                        color: ShellSettings.colors.active.darker(1.5)
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        Layout.preferredHeight: contentHeight
                    }
                }

                RowLayout {
                    spacing: 2
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 4

                    StyledMouseArea {
                        Layout.preferredWidth: this.height
                        Layout.fillHeight: true
                        enabled: Bluetooth.defaultAdapter !== null

                        onClicked: {
                            if (Bluetooth.defaultAdapter) {
                                Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
                            }
                        }

                        IconImage {
                            source: {
                                if (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled) {
                                    return "image://icon/bluetooth-offline";
                                } else {
                                    return "image://icon/bluetooth-online";
                                }
                            }

                            anchors {
                                fill: parent
                                margins: 2
                            }
                        }
                    }

                    StyledMouseArea {
                        Layout.preferredWidth: this.height
                        Layout.fillHeight: true
                        enabled: Bluetooth.defaultAdapter !== null

                        onClicked: {
                            if (Bluetooth.defaultAdapter) {
                                Bluetooth.defaultAdapter.discovering = !Bluetooth.defaultAdapter.discovering;
                            }
                        }

                        IconImage {
                            id: searchIcon
                            transformOrigin: Item.Center

                            source: {
                                if (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.discovering) {
                                    return "image://icon/reload";
                                } else {
                                    return "image://icon/cm_search";
                                }
                            }

                            anchors {
                                fill: parent
                                margins: 2
                            }

                            NumberAnimation on rotation {
                                from: 0
                                to: 360
                                duration: 900
                                loops: Animation.Infinite
                                running: Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.discovering
                                onRunningChanged: {
                                    if (!running)
                                        searchIcon.rotation = 0;
                                }
                            }
                        }
                    }
                }
            }

            // Devices
            StyledListView {
                id: appList
                spacing: 2
                model: Bluetooth.devices
                clip: true

                Layout.fillWidth: true
                Layout.preferredHeight: {
                    const entryHeight = Math.min(8, Bluetooth.devices && Bluetooth.devices.values ? Bluetooth.devices.values.length : 0);

                    return entryHeight * (menu.entryHeight + appList.spacing);
                }

                delegate: BluetoothCard {
                    device: modelData
                    width: ListView.view.width
                    height: menu.entryHeight

                    required property BluetoothDevice modelData
                }
            }
        }
    }
}
