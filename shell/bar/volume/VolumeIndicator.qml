pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
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
                id: defaultCard
                node: menu.sink
                Layout.fillWidth: true
                Layout.preferredHeight: menu.entryHeight

                leftWidget: StyledMouseArea {
                    onClicked: defaultCard.node.audio.muted = !defaultCard.node.audio.muted

                    IconImage {
                        anchors.fill: parent
                        source: {
                            if (defaultCard.node.audio.muted) {
                                return "root:resources/volume/volume-mute.svg";
                            } else {
                                return "root:resources/volume/volume-full.svg";
                            }
                        }
                    }
                }
            }

            Rectangle {
                visible: linkTracker.linkGroups.length !== 0
                color: ShellSettings.colors.active_translucent
                radius: height / 2
                Layout.leftMargin: 3
                Layout.rightMargin: 3
                Layout.fillWidth: true
                Layout.preferredHeight: 2
            }

            // Application Mixer
            PwNodeLinkTracker {
                id: linkTracker
                node: menu.sink
            }

            StyledListView {
                id: appList
                visible: linkTracker.linkGroups.length !== 0
                spacing: 6
                model: linkTracker.linkGroups
                clip: true

                Layout.fillWidth: true
                Layout.preferredHeight: {
                    const entryHeight = Math.min(5, linkTracker.linkGroups.length);

                    return entryHeight * (menu.entryHeight + appList.spacing);
                }

                delegate: VolumeCard {
                    id: appCard
                    node: modelData.source
                    label: node.properties["media.name"] ?? ""
                    width: ListView.view.width
                    height: menu.entryHeight

                    required property PwLinkGroup modelData

                    leftWidget: StyledMouseArea {
                        onClicked: appCard.node.audio.muted = !appCard.node.audio.muted

                        IconImage {
                            id: appIcon
                            visible: false
                            anchors.fill: parent

                            source: {
                                if (appCard.node.properties["application.icon-name"] !== undefined)
                                    return `image://icon/${appCard.node.properties["application.icon-name"]}`;

                                let applicationName = appCard.node.properties["application.name"];
                                return `image://icon/${applicationName?.toLowerCase() ?? "image-missing"}`;
                            }
                        }

                        MultiEffect {
                            source: appIcon
                            anchors.fill: appIcon
                            saturation: appCard.node.audio.muted ? -1.0 : 0.0
                        }
                    }
                }
            }
        }
    }
}
