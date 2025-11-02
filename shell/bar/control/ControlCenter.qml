pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import qs.widgets
import qs.bar

StyledMouseArea {
    id: root
    onClicked: showMenu = !showMenu

    required property var bar
    property bool showMenu: false

    IconImage {
        id: icon
        source: "root:resources/control/controls-button.svg"

        anchors {
            fill: parent
            margins: 3
        }
    }

    property PopupItem menu: PopupItem {
        id: menu
        owner: root
        popup: root.bar.popup
        show: root.showMenu
        onClosed: root.showMenu = false

        property real padding: 10

        implicitWidth: 275
        implicitHeight: 350 

        ColumnLayout {
            id: container
            spacing: 4

            anchors {
                fill: parent
                margins: 8
            }

            ControlCenterCard {
                title: "Wi-Fi"
                description: "Wifi Network"
                Layout.fillWidth: true
                Layout.preferredHeight: 40
            }

            ControlCenterCard {
                title: "Bluetooth"
                description: "Manage bluetooth devices."
                Layout.fillWidth: true
                Layout.preferredHeight: 40
            }

            // ControlCenterCard {
            //     title: "Bluetooth"
            //     description: "Manage bluetooth devices."
            //     Layout.fillWidth: true
            //     Layout.preferredHeight: 40
            // }
            //
            // ControlCenterCard {
            //     title: "Bluetooth"
            //     description: "Manage bluetooth devices."
            //     Layout.fillWidth: true
            //     Layout.preferredHeight: 40
            // }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
}
