pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import "../../widgets/" as Widgets
import "../.."

ColumnLayout {
    id: root

    // headphones
    // don't load until the node is not null
    Loader {
        id: sinkLoader
        active: sink !== null 
        Layout.preferredWidth: 350
        Layout.preferredHeight: 45

        property PwNode sink: Pipewire.defaultAudioSink

        sourceComponent: VolumeCard {
            id: sinkCard
            node: sinkLoader.sink
            button: Widgets.FontIconButton {
                hoverEnabled: false
                iconName: sinkCard.node.audio.muted ? "volume_off" : "volume_up"
                checked: !sinkCard.node.audio.muted
                inactiveColor: ShellSettings.colors["surface_container_highest"]
                onClicked: {
                    sinkCard.node.audio.muted = !sinkCard.node.audio.muted;
                }
            }

            anchors.fill: parent
        }
    }

    // microphone, same as above
    Loader {
        id: sourceLoader
        active: source !== null 
        Layout.preferredWidth: 350
        Layout.preferredHeight: 45

        property PwNode source: Pipewire.defaultAudioSource

        sourceComponent: VolumeCard {
            id: sourceCard
            node: sourceLoader.source
            button: Widgets.FontIconButton {
                hoverEnabled: false
                iconName: sourceCard.node.audio.muted ? "mic_off" : "mic"
                checked: !sourceCard.node.audio.muted
                inactiveColor: ShellSettings.colors["surface_container_highest"]
                onClicked: {
                    sourceCard.node.audio.muted = !sourceCard.node.audio.muted;
                }
            }

            anchors.fill: parent
        }
    }
}
