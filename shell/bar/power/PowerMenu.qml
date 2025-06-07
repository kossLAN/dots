pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.UPower
import qs.widgets
import qs.bar
import qs

StyledMouseArea {
    id: root
    implicitWidth: height
    onClicked: showMenu = !showMenu
    visible: UPower.displayDevice.isLaptopBattery

    required property var bar
    property bool showMenu: false

    // Filter devices that have batteries (percentage > 0), excluding laptop battery
    property var batteryDevices: {
        let devices = [];

        if (UPower.devices && UPower.devices.values) {
            for (let i = 0; i < UPower.devices.values.length; i++) {
                const dev = UPower.devices.values[i];

                if (dev.percentage > 0 && dev.ready && !dev.isLaptopBattery) {
                    devices.push(dev);
                }
            }
        }

        return devices;
    }

    IconImage {
        anchors.fill: parent
        source: {
            if (!UPower.displayDevice || !UPower.displayDevice.ready)
                return Quickshell.iconPath("gpm-battery-missing");

            const percentage = UPower.displayDevice.percentage;
            const isCharging = UPower.displayDevice.state === 1; // 1 = Charging

            // Use gpm-primary icons for laptop battery
            let iconName = "gpm-primary-";

            if (percentage >= 0.95) {
                iconName += "100";
            } else if (percentage >= 0.75) {
                iconName += "080";
            } else if (percentage >= 0.55) {
                iconName += "060";
            } else if (percentage >= 0.35) {
                iconName += "040";
            } else if (percentage >= 0.15) {
                iconName += "020";
            } else {
                iconName += "000";
            }

            if (isCharging) {
                iconName += "-charging";
            }

            return Quickshell.iconPath(iconName);
        }
    }

    property PopupItem menu: PopupItem {
        id: menu
        owner: root
        popup: root.bar.popup
        show: root.showMenu
        onClosed: root.showMenu = false

        implicitWidth: 270
        implicitHeight: container.implicitHeight + (2 * container.anchors.margins)

        property var entryHeight: 38

        ColumnLayout {
            id: container
            spacing: 2

            anchors {
                fill: parent
                margins: 4
            }

            BatteryCard {
                device: UPower.displayDevice
                visible: UPower.displayDevice.isLaptopBattery
                Layout.fillWidth: true
                Layout.preferredHeight: menu.entryHeight
            }

            StyledListView {
                id: deviceList
                spacing: 2
                model: root.batteryDevices
                clip: true
                visible: root.batteryDevices.length > 0

                Layout.fillWidth: true
                Layout.preferredHeight: {
                    const entryCount = Math.min(6, root.batteryDevices.length);
                    return entryCount * (menu.entryHeight + deviceList.spacing);
                }

                delegate: BatteryCard {
                    device: modelData
                    width: ListView.view.width
                    height: menu.entryHeight

                    required property UPowerDevice modelData
                }
            }

            StyledText {
                text: "No battery devices found"
                color: ShellSettings.colors.active.windowText.darker(1.5)
                horizontalAlignment: Text.AlignHCenter
                visible: !UPower.displayDevice.isLaptopBattery && root.batteryDevices.length === 0
                Layout.fillWidth: true
                Layout.topMargin: 8
                Layout.bottomMargin: 8
            }
        }
    }
}
