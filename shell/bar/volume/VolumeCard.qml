pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import qs
import qs.widgets

Loader {
    id: root
    active: node !== null

    required property PwNode node

    sourceComponent: WrapperRectangle {
        id: comp
        color: ShellSettings.colors.surface_container_translucent
        radius: 12 
        margin: 6

        border {
            width: 1
            color: ShellSettings.colors.active_translucent
        }

        // property string text
        // property Component button
        // property Component icon

        PwObjectTracker {
            id: tracker
            objects: [root.node]
        }

        RowLayout {
            Slider {
                value: root.node.audio.volume ?? 0
                // text: root.text
                // icon: root.icon

                onValueChanged: {
                    // only allow changes when the node is ready other wise you will combust
                    if (!root.node.ready)
                        return;

                    root.node.audio.volume = value;
                }

                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            // Loader {
            //     id: buttonLoader
            //     sourceComponent: root.button
            //
            //     Layout.preferredWidth: this.height
            //     Layout.fillHeight: true
            // }
        }
    }

    // sourceComponent: VolumeCard {
    //     id: sinkCard
    //     node: sinkLoader.sink
    //     button: StyledMouseArea {
    //         property bool checked: !sinkCard.node.audio.muted
    //
    //         // IconImage {}
    //
    //         onClicked: {
    //             sinkCard.node.audio.muted = !sinkCard.node.audio.muted;
    //         }
    //     }
    //
    //     anchors.fill: parent
    // }
}
