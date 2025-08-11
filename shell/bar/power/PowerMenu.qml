pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell.Widgets
import Quickshell.Services.UPower
import qs.widgets
import qs.bar
import qs

// todo: redo the tray icon handling
StyledMouseArea {
    id: root
    implicitWidth: height + 8 // for margin
    visible: UPower.displayDevice.isLaptopBattery
    onClicked: showMenu = !showMenu

    required property var bar
    property bool showMenu: false

    Item {
        implicitWidth: parent.height
        implicitHeight: parent.height
        anchors.centerIn: parent
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
            color: Qt.color(ShellSettings.colors["surface"]).lighter(4)
            opacity: 0.75
            anchors {
                fill: parent
                margins: 2
            }
        }

        Rectangle {
            id: batteryPercentage
            width: (parent.width - 4) * UPower.displayDevice.percentage
            color: ShellSettings.colors["inverse_surface"]

            anchors {
                left: batteryBackground.left
                top: batteryBackground.top
                bottom: batteryBackground.bottom
            }
        }
    }

    property PopupItem menu: PopupItem {
        owner: root
        popup: root.bar.popup
        show: root.showMenu
        onClosed: root.showMenu = false
        centered: true

        implicitWidth: 250 
        implicitHeight: 250 
    }
}
