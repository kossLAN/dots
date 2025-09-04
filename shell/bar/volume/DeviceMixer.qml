pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import qs
import qs.widgets

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
            button: StyledMouseArea {
                property bool checked: !sinkCard.node.audio.muted

                // IconImage {}

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
            button: StyledMouseArea {
                property bool checked: !sourceCard.node.audio.muted

                // IconImage {}

                onClicked: {
                    sourceCard.node.audio.muted = !sourceCard.node.audio.muted;
                }
            }

            anchors.fill: parent
        }
    }
}
