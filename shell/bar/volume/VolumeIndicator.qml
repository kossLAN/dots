pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import qs.widgets
import qs.bar
import qs

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

        property PwNode sink: Pipewire.defaultAudioSink
        property real entryHeight: 45

        ColumnLayout {
            id: container
            spacing: 4

            anchors {
                fill: parent
                margins: 8
            }

            // Default Audio
            VolumeCard {
                node: menu.sink
                Layout.fillWidth: true
                Layout.preferredHeight: menu.entryHeight
            }

            Rectangle {
                color: ShellSettings.colors.active_translucent
                radius: height / 2
                Layout.leftMargin: 3
                Layout.rightMargin: 3
                Layout.fillWidth: true
                Layout.preferredHeight: 2
            }

            // Application Mixer
            Loader {
                id: sinkLoader
                active: menu.sink

                Layout.fillWidth: true
                Layout.preferredHeight: 5 * menu.entryHeight

                PwNodeLinkTracker {
                    id: linkTracker
                    node: menu.sink
                }

                sourceComponent: ListView {
                    anchors.fill: parent
                    spacing: 6
                    model: linkTracker.linkGroups

                    delegate: Loader {
                        id: nodeLoader
                        active: modelData.source != null
                        width: ListView.view.width
                        height: menu.entryHeight

                        required property PwLinkGroup modelData

                        sourceComponent: VolumeCard {
                            node: nodeLoader.modelData.source 
                            label: node.properties["media.name"] ?? ""
                        }
                    }
                }
            }
        }
    }
}
