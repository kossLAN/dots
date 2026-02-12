import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs.widgets
import qs

Item {
    id: root

    required property UPowerDevice device

    function formatTime(seconds) {
        if (seconds <= 0 || !isFinite(seconds))
            return "";

        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);

        if (hours > 0) {
            return hours + "h " + minutes + "m";
        } else {
            return minutes + "m";
        }
    }

    function getDeviceTypeName() {
        if (!root.device)
            return "Device";

        const typeName = UPowerDeviceType.toString(root.device.type);
        if (typeName && typeName !== "")
            return typeName;

        return "Device";
    }

    RowLayout {
        spacing: 8
        anchors.fill: parent

        BatteryIcon {
            device: root.device
            Layout.preferredWidth: this.height
            Layout.fillHeight: true
            Layout.margins: 4
        }

        ColumnLayout {
            spacing: 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter

            StyledText {
                text: {
                    if (!root.device)
                        return "Unknown Device";
                    if (root.device.isLaptopBattery)
                        return "Laptop Battery";
                    const model = root.device.model;
                    return model !== "" ? model : root.getDeviceTypeName();
                }
                color: ShellSettings.colors.active.windowText
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
            }

            StyledText {
                text: root.device ? Math.round(root.device.percentage * 100) + "%" : "?"
                color: ShellSettings.colors.active.windowText.darker(1.5)
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
            }
        }

        StyledText {
            color: ShellSettings.colors.active.windowText.darker(1.3)
            visible: root.device && ((root.device.state === 1 && root.device.timeToFull > 0) || (root.device.state === 2 && root.device.timeToEmpty > 0))
            text: root.device ? root.formatTime(root.device.state === 1 ? root.device.timeToFull : root.device.timeToEmpty) : ""
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: 8
        }
    }
}
