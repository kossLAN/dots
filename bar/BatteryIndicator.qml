pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell.Widgets
import Quickshell.Services.UPower
import ".."

Item {
    id: root

    implicitWidth: 22
    implicitHeight: 22
    visible: UPower.displayDevice.isLaptopBattery

    layer.enabled: true
    layer.effect: OpacityMask {
        source: Rectangle {
            width: root.width
            height: root.height
            color: "white"
        }

        maskSource: IconImage {
            implicitSize: root.width
            source: "root:resources/battery/battery.svg"
        }
    }

    Rectangle {
        id: batteryBackground
        color: Qt.color(ShellSettings.settings.colors["surface"]).lighter(4)
        opacity: 0.75
        anchors {
            fill: parent
            margins: 2
        }
    }

    Rectangle {
        id: batteryPercentage
        width: (parent.width - 4) * UPower.displayDevice.percentage
        color: ShellSettings.settings.colors["inverse_surface"]
        anchors {
            left: batteryBackground.left
            top: batteryBackground.top
            bottom: batteryBackground.bottom
        }
    }
}
