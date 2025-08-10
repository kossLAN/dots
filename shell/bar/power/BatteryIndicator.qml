pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Widgets
import Quickshell.Services.UPower
import "../../widgets" as Widgets
import "../.."

// todo: redo the tray icon handling
Item {
    id: root
    implicitWidth: height + 8 // for margin
    visible: UPower.displayDevice.isLaptopBattery

    required property var popup

    Widgets.StyledMouseArea {
        id: batteryButton
        hoverEnabled: true
        onClicked: {
            if (root.popup.content == powerMenu) {
                root.popup.hide();
                return;
            }

            root.popup.set(this, powerMenu);
        }

        anchors {
            fill: parent
            margins: 1
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
    }

    Item {
        id: powerMenu
        visible: false
        implicitWidth: 250
        implicitHeight: 80

        RowLayout {
            anchors.fill: parent

            // ComboBox {
            //     model: ScriptModel {
            //         values: ["Power Save", "Balanced", "Performance"]
            //     }
            //
            //     currentIndex: PowerProfiles.profile
            //     onCurrentIndexChanged: {
            //         PowerProfiles.profile = this.currentIndex;
            //         console.log(PowerProfile.toString(PowerProfiles.profile));
            //     }
            // }
        }
    }
}
