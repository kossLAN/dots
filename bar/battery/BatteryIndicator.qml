pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Widgets
import Quickshell.Services.UPower
import "../.."

Item {
    id: root
    implicitWidth: parent.height + 8
    implicitHeight: parent.height
    visible: UPower.displayDevice.isLaptopBattery

    required property var popup

    MouseArea {
        id: batteryButton
        hoverEnabled: true
        anchors.fill: parent
        onClicked: {
            if (root.popup.content == powerMenu) {
                root.popup.hide();
                return;
            }

            root.popup.set(this, powerMenu);
            root.popup.show();
        }
    }

    Item {
        id: powerMenu
        visible: false
        implicitWidth: 250
        implicitHeight: 80

        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log("why this work");
                powerMenu.implicitWidth = 300;
            }
        }

        RowLayout {
            anchors.fill: parent

            // placeholder for now
            ComboBox {
                model: ["Power Save", "Balanced", "Performance"]
                currentIndex: PowerProfiles.profile
                onCurrentIndexChanged: PowerProfiles.profile = currentIndex
            }
        }
    }

    Rectangle {
        id: highlight
        color: batteryButton.containsMouse ? ShellSettings.settings.colors["primary"] : "transparent"
        // radius: width / 2
        radius: 10

        anchors {
            fill: parent
            // topMargin: 2
            // bottomMargin: 2
        }

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }
    }

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
}
