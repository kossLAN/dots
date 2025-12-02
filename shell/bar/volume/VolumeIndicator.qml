pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import qs.widgets
import qs.bar

StyledMouseArea {
    id: root
    onClicked: showMenu = !showMenu

    required property var bar
    property bool showMenu: false
    property PwNode sink: Pipewire.defaultAudioSink

    IconImage {
        id: icon
        anchors.fill: parent
        source: if (root.sink?.audio?.muted) {
            return "image://icon/audio-volume-muted";
        } else if (root.sink?.audio && root.sink.audio.volume > 0.66) {
            return "image://icon/audio-volume-high";
        } else if (root.sink?.audio && root.sink.audio.volume > 0.33) {
            return "image://icon/audio-volume-medium";
        } else {
            return "image://icon/audio-volume-low";
        }
    }

    property PopupItem menu: PopupItem {
        id: menu
        owner: root
        popup: root.bar.popup
        show: root.showMenu
        onClosed: root.showMenu = false

        implicitWidth: 275
        implicitHeight: container.implicitHeight + (2 * container.anchors.margins)

        property real entryHeight: 38

        ColumnLayout {
            id: container
            spacing: 2

            anchors {
                fill: parent
                margins: 4
            }

            // Default Audio
            VolumeCard {
                id: defaultCard
                node: root.sink
                Layout.fillWidth: true
                Layout.preferredHeight: menu.entryHeight

                leftWidget: StyledMouseArea {
                    enabled: defaultCard.node?.audio !== null && defaultCard.node?.audio !== undefined
                    onClicked: {
                        if (defaultCard.node?.audio) {
                            defaultCard.node.audio.muted = !defaultCard.node.audio.muted;
                        }
                    }

                    IconImage {
                        anchors.fill: parent
                        source: if (root.sink?.audio?.muted) {
                            return "image://icon/audio-volume-muted";
                        } else if (root.sink?.audio && root.sink.audio.volume > 0.66) {
                            return "image://icon/audio-volume-high";
                        } else if (root.sink?.audio && root.sink.audio.volume > 0.33) {
                            return "image://icon/audio-volume-medium";
                        } else {
                            return "image://icon/audio-volume-low";
                        }
                    }
                }
            }

            // Application Mixer
            PwNodeLinkTracker {
                id: linkTracker
                node: root.sink
            }

            StyledListView {
                id: appList
                visible: linkTracker.linkGroups.length !== 0
                spacing: 2
                model: linkTracker.linkGroups
                clip: true

                Layout.fillWidth: true
                Layout.preferredHeight: {
                    const entryHeight = Math.min(6, linkTracker.linkGroups.length);

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
                        enabled: appCard.node?.audio !== null && appCard.node?.audio !== undefined
                        onClicked: {
                            if (appCard.node?.audio) {
                                appCard.node.audio.muted = !appCard.node.audio.muted;
                            }
                        }

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
                            saturation: appCard.node?.audio?.muted ? -1.0 : 0.0
                        }
                    }
                }
            }
        }
    }
}
