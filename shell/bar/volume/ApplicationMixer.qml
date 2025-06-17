pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import "../../widgets/" as Widgets
import "../.."

ColumnLayout {
    id: root

    Loader {
        id: sinkLoader
        active: sink

        property PwNode sink: Pipewire.defaultAudioSink

        sourceComponent: WrapperItem {
            PwNodeLinkTracker {
                id: linkTracker
                node: sinkLoader.sink
            }

            ColumnLayout {
                Repeater {
                    model: linkTracker.linkGroups

                    delegate: Loader {
                        id: nodeLoader
                        active: modelData.source !== null
                        Layout.preferredWidth: 350
                        Layout.preferredHeight: 45

                        required property PwLinkGroup modelData

                        sourceComponent: VolumeCard {
                            id: nodeCard
                            node: nodeLoader.modelData.source
                            text: node.properties["media.name"] ?? ""

                            // if icon-name is undefined, just gonna fallback on the application name
                            icon: IconImage {
                                source: {
                                    if (nodeCard.node.properties["application.icon-name"] !== undefined)
                                        return `image://icon/${nodeCard.node.properties["application.icon-name"]}`;

                                    let applicationName = nodeCard.node.properties["application.name"];
                                    return `image://icon/${applicationName?.toLowerCase() ?? "image-missing"}`;
                                }
                            }

                            button: Widgets.FontIconButton {
                                hoverEnabled: false
                                iconName: nodeCard.node.audio.muted ? "volume_off" : "volume_up"
                                checked: !nodeCard.node.audio.muted
                                inactiveColor: ShellSettings.colors["surface_container_highest"]
                                onClicked: {
                                    nodeCard.node.audio.muted = !nodeCard.node.audio.muted;
                                }
                            }

                            anchors.fill: parent
                        }
                    }
                }
            }
        }
    }
}
