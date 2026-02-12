pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Networking
import qs.widgets
import qs.bar
import qs.bar.tray
import qs

TrayBacker {
    id: root

    trayId: "wifi"

    property WifiDevice wifiDevice: {
        if (!Networking.devices)
            return null;
        for (let i = 0; i < Networking.devices.values.length; i++) {
            const dev = Networking.devices.values[i];
            if (dev.type === DeviceType.Wifi) {
                return dev;
            }
        }
        return null;
    }

    property bool ethernetConnected: {
        if (!Networking.devices)
            return false;
        for (let i = 0; i < Networking.devices.values.length; i++) {
            const dev = Networking.devices.values[i];

            // Currently is no Ethernet device type... hopefully added later
            if (dev.type !== DeviceType.Wifi && dev.connected) {
                return true;
            }
        }
        return false;
    }

    icon: StyledMouseArea {
        onClicked: root.clicked()

        IconImage {
            anchors.fill: parent
            source: {
                if (root.ethernetConnected) {
                    return Quickshell.iconPath("network-wired");
                }

                if (Networking.wifiEnabled && root.wifiDevice && root.wifiDevice.connected) {
                    if (root.wifiDevice.networks) {
                        for (let i = 0; i < root.wifiDevice.networks.values.length; i++) {
                            const net = root.wifiDevice.networks.values[i];

                            if (net.connected) {
                                const strength = net.signalStrength;

                                if (strength >= 0.75)
                                    return Quickshell.iconPath("network-wireless-80");
                                if (strength >= 0.5)
                                    return Quickshell.iconPath("network-wireless-60");
                                if (strength >= 0.25)
                                    return Quickshell.iconPath("network-wireless-40");

                                return Quickshell.iconPath("network-wireless-20");
                            }
                        }
                    }
                }

                return Quickshell.iconPath("network-wireless-100");
            }
        }
    }

    menu: Item {
        id: menu
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

            RowLayout {
                spacing: 2

                Layout.fillWidth: true
                Layout.preferredHeight: menu.entryHeight

                IconImage {
                    Layout.preferredWidth: this.height
                    Layout.fillHeight: true
                    Layout.margins: 4

                    source: {
                        if (Networking.wifiEnabled && root.wifiDevice) {
                            return Quickshell.iconPath("network-wireless-100");
                        } else {
                            return Quickshell.iconPath("network-wireless-100");
                        }
                    }
                }

                ColumnLayout {
                    spacing: 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter

                    StyledText {
                        text: root.wifiDevice ? `WiFi (${root.wifiDevice.name})` : "WiFi (No Device)"
                        color: ShellSettings.colors.active.windowText
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        Layout.preferredHeight: contentHeight
                    }

                    StyledText {
                        text: {
                            if (!root.wifiDevice)
                                return "Not Available";
                            if (!Networking.wifiEnabled)
                                return "Disabled";
                            if (root.wifiDevice.connected)
                                return "Connected";
                            return "Disconnected";
                        }
                        color: ShellSettings.colors.active.windowText.darker(1.5)
                        elide: Text.ElideRight

                        Layout.fillWidth: true
                        Layout.preferredHeight: contentHeight
                    }
                }

                ToggleSwitch {
                    checked: Networking.wifiEnabled
                    enabled: Networking.wifiHardwareEnabled

                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: 4

                    onCheckedChanged: {
                        if (Networking.wifiEnabled !== checked) {
                            Networking.wifiEnabled = checked;

                            if (checked && root.wifiDevice) {
                                root.wifiDevice.scannerEnabled = true;
                            }
                        }
                    }
                }
            }

            StyledListView {
                id: networkList
                spacing: 2
                model: root.wifiDevice ? root.wifiDevice.networks : null
                clip: true

                Layout.fillWidth: true
                Layout.preferredHeight: {
                    const networks = root.wifiDevice && root.wifiDevice.networks ? root.wifiDevice.networks.values : null;
                    const entryCount = Math.min(8, networks ? networks.length : 0);
                    return entryCount * (menu.entryHeight + networkList.spacing);
                }

                delegate: WifiCard {
                    network: modelData
                    width: ListView.view.width
                    height: menu.entryHeight

                    required property WifiNetwork modelData
                }
            }
        }
    }
}
