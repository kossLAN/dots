pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Networking
import Quickshell.Widgets
import qs
import qs.widgets

SettingsBacker {
    icon: "network-wireless"

    content: Item {
        id: container

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

        Component.onCompleted: {
            if (wifiDevice && Networking.wifiEnabled) {
                wifiDevice.scannerEnabled = true;
            }
        }

        Component.onDestruction: {
            if (wifiDevice) {
                wifiDevice.scannerEnabled = false;
            }
        }

        ColumnLayout {
            id: root
            spacing: 6

            anchors.fill: parent

            // Adapter Section
            StyledRectangle {
                id: adapterCard
                color: ShellSettings.colors.active.base
                clip: true

                Layout.fillWidth: true
                Layout.preferredHeight: adapterContent.implicitHeight + 12

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: adapterCard.width
                        height: adapterCard.height
                        radius: adapterCard.radius
                        color: "black"
                    }
                }

                ColumnLayout {
                    id: adapterContent
                    spacing: 6

                    anchors {
                        fill: parent
                        margins: 6
                    }

                    RowLayout {
                        spacing: 6
                        Layout.fillWidth: true

                        IconImage {
                            source: {
                                if (Networking.wifiEnabled && container.wifiDevice) {
                                    return Quickshell.iconPath("network-wireless-100");
                                } else {
                                    return Quickshell.iconPath("network-wireless-offline");
                                }
                            }

                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                        }

                        ColumnLayout {
                            spacing: 1
                            Layout.fillWidth: true

                            StyledText {
                                text: container.wifiDevice ? `WiFi (${container.wifiDevice.name})` : "No WiFi Device"
                                font.pointSize: 9
                            }

                            StyledText {
                                text: {
                                    if (!container.wifiDevice)
                                        return "Not Available";
                                    if (!Networking.wifiEnabled)
                                        return "Disabled";
                                    if (container.wifiDevice.connected)
                                        return "Connected";
                                    return "Disconnected";
                                }
                                color: ShellSettings.colors.active.windowText.darker(1.5)
                                font.pointSize: 9
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        ToggleSwitch {
                            checked: Networking.wifiEnabled
                            enabled: Networking.wifiHardwareEnabled

                            Layout.alignment: Qt.AlignVCenter

                            onCheckedChanged: {
                                if (Networking.wifiEnabled !== checked) {
                                    Networking.wifiEnabled = checked;

                                    if (checked && container.wifiDevice) {
                                        container.wifiDevice.scannerEnabled = true;
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Networks Section Header
            RowLayout {
                spacing: 6
                Layout.fillWidth: true

                StyledText {
                    text: "Networks"
                    font.pointSize: 9
                }

                Item {
                    Layout.fillWidth: true
                }

                StyledText {
                    text: {
                        const networks = container.wifiDevice?.networks?.values;
                        return networks ? `${networks.length} found` : "0 found";
                    }
                    color: ShellSettings.colors.active.windowText.darker(1.5)
                    font.pointSize: 9
                }
            }

            Separator {
                Layout.fillWidth: true
            }

            // Network List
            StyledListView {
                id: networkList
                model: container.wifiDevice ? container.wifiDevice.networks : null
                spacing: 4
                clip: true
                visible: networkList.count > 0

                Layout.fillWidth: true
                Layout.fillHeight: true

                delegate: StyledRectangle {
                    id: networkCard
                    color: ShellSettings.colors.active.base
                    clip: true

                    required property WifiNetwork modelData
                    property bool expanded: false
                    property int collapsedHeight: 52
                    property int expandedHeight: 56 + dropdownContent.implicitHeight

                    implicitWidth: ListView.view.width
                    implicitHeight: expanded ? expandedHeight : collapsedHeight

                    MouseArea {
                        anchors.fill: parent
                        onClicked: networkCard.expanded = !networkCard.expanded
                    }

                    Behavior on implicitHeight {
                        SmoothedAnimation {
                            duration: 200
                        }
                    }

                    RowLayout {
                        id: mainRow
                        spacing: 8
                        height: 36

                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            margins: 8
                        }

                        IconImage {
                            source: {
                                if (!networkCard.modelData)
                                    return Quickshell.iconPath("network-wireless-100");

                                const strength = networkCard.modelData.signalStrength;

                                if (strength >= 0.75)
                                    return Quickshell.iconPath("network-wireless-80");
                                if (strength >= 0.5)
                                    return Quickshell.iconPath("network-wireless-60");
                                if (strength >= 0.25)
                                    return Quickshell.iconPath("network-wireless-40");

                                return Quickshell.iconPath("network-wireless-20");
                            }

                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                        }

                        ColumnLayout {
                            spacing: 4
                            Layout.fillWidth: true

                            StyledText {
                                text: networkCard.modelData && networkCard.modelData.name ? networkCard.modelData.name : "Unknown Network"
                                font.pointSize: 9
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                spacing: 4
                                Layout.fillWidth: true

                                Rectangle {
                                    radius: 3

                                    color: {
                                        if (!networkCard.modelData)
                                            return ShellSettings.colors.active.dark;
                                        if (networkCard.modelData.connected)
                                            return "#4CAF50";
                                        if (networkCard.modelData.known)
                                            return "#2196F3";

                                        return ShellSettings.colors.active.dark;
                                    }

                                    Layout.preferredWidth: statusText.implicitWidth + 6
                                    Layout.preferredHeight: statusText.implicitHeight + 2

                                    StyledText {
                                        id: statusText
                                        font.pointSize: 9
                                        color: "white"
                                        anchors.centerIn: parent

                                        text: {
                                            if (!networkCard.modelData)
                                                return "Unknown";
                                            if (networkCard.modelData.stateChanging)
                                                return "Connecting...";
                                            if (networkCard.modelData.connected)
                                                return "Connected";
                                            if (networkCard.modelData.known)
                                                return "Saved";

                                            return "Available";
                                        }
                                    }
                                }
                            }
                        }

                        // Connect/Disconnect Button
                        StyledMouseArea {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24

                            onClicked: {
                                if (networkCard.modelData) {
                                    if (networkCard.modelData.connected) {
                                        networkCard.modelData.disconnect();
                                    } else {
                                        networkCard.modelData.connect();
                                    }
                                }
                            }

                            IconImage {
                                source: {
                                    if (networkCard.modelData && networkCard.modelData.connected) {
                                        return Quickshell.iconPath("network-disconnect-symbolic");
                                    } else {
                                        return Quickshell.iconPath("network-connect-symbolic");
                                    }
                                }
                                anchors.fill: parent
                                anchors.margins: 2
                            }
                        }

                        ExpandArrow {
                            expanded: networkCard.expanded
                            visible: networkCard.modelData && networkCard.modelData.known

                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                        }
                    }

                    ColumnLayout {
                        id: dropdownContent
                        spacing: 6
                        opacity: networkCard.expanded ? 1 : 0
                        visible: opacity > 0 && networkCard.modelData && networkCard.modelData.known

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 150
                            }
                        }

                        anchors {
                            top: mainRow.bottom
                            left: parent.left
                            right: parent.right
                            margins: 8
                            topMargin: 4
                        }

                        Rectangle {
                            color: ShellSettings.colors.active.mid
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                        }

                        // Forget Button
                        StyledButton {
                            enabled: networkCard.modelData !== null && networkCard.modelData.known

                            Layout.fillWidth: true
                            Layout.preferredHeight: 24

                            onClicked: {
                                if (networkCard.modelData) {
                                    networkCard.modelData.forget();
                                    networkCard.expanded = false;
                                }
                            }

                            RowLayout {
                                spacing: 4
                                anchors.centerIn: parent

                                IconImage {
                                    source: Quickshell.iconPath("edit-delete")
                                    Layout.preferredWidth: 14
                                    Layout.preferredHeight: 14
                                }

                                StyledText {
                                    text: "Forget Network"
                                    font.pointSize: 9
                                }
                            }
                        }
                    }
                }
            }

            // Empty state
            Item {
                visible: networkList.count === 0
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12

                    IconImage {
                        source: Quickshell.iconPath("network-wireless-100")
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        Layout.alignment: Qt.AlignHCenter
                        opacity: 0.5
                    }

                    StyledText {
                        horizontalAlignment: Text.AlignHCenter
                        color: ShellSettings.colors.active.windowText.darker(1.5)
                        font.pointSize: 9

                        text: {
                            if (!container.wifiDevice)
                                return "No WiFi device found";
                            if (!Networking.wifiEnabled)
                                return "WiFi is disabled\nEnable it to see networks";
                            return "No networks found\nEnable scanning to discover networks";
                        }

                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }
}
