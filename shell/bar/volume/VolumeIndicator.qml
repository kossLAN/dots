pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import qs.widgets
import qs.bar

StyledMouseArea {
    id: root
    onClicked: showMenu = !showMenu

    required property var bar
    property bool showMenu: false

    IconImage {
        id: icon
        source: "root:resources/volume/volume-full.svg"

        anchors {
            fill: parent
            margins: 2
        }
    }

    property PopupItem menu: PopupItem {
        id: menu
        owner: root
        popup: root.bar.popup
        show: root.showMenu
        onClosed: root.showMenu = false

        implicitWidth: 300
        implicitHeight: container.implicitHeight + (2 * 8)

        // implicitWidth: volumeMenu.implicitWidth
        // implicitHeight: volumeMenu.implicitHeight

        // VolumeControl {
        //     id: volumeMenu
        // }

        ColumnLayout {
            id: container

            anchors {
                fill: parent
                margins: 8
            }

            VolumeCard {
                node: Pipewire.defaultAudioSink
                Layout.fillWidth: true
                Layout.preferredHeight: 45
            }

            VolumeCard {
                node: Pipewire.defaultAudioSource
                Layout.fillWidth: true
                Layout.preferredHeight: 45
            }
        }
    }
}
