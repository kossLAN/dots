pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import "../../widgets/" as Widgets
import "../.."

WrapperItem {
    id: root
    visible: false

    ColumnLayout {
        spacing: 5

        // Toolbar
        Rectangle {
            id: toolbar
            color: ShellSettings.colors["surface_container_highest"]
            radius: 10
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: toolbar.width
                    height: toolbar.height
                    radius: toolbar.radius
                    color: "black"
                }
            }

            Layout.fillWidth: true
            Layout.preferredHeight: 35

            RowLayout {
                spacing: 0
                anchors.fill: parent

                Widgets.FontIconButton {
                    hoverEnabled: false
                    iconName: "headphones"
                    radius: 0
                    checked: page.currentIndex === 0
                    onClicked: page.currentIndex = 0

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                Widgets.FontIconButton {
                    hoverEnabled: false
                    iconName: "tune"
                    radius: 0
                    checked: page.currentIndex === 1
                    onClicked: page.currentIndex = 1

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }

        StackLayout {
            id: page
            currentIndex: 0
            Layout.fillWidth: true
            Layout.preferredHeight: currentItem ? currentItem.implicitHeight : 0

            readonly property Item currentItem: children[currentIndex]

            DeviceMixer {}
            ApplicationMixer {}
        }
    }
}
