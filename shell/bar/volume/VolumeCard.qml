pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import qs.widgets
import qs

Loader {
    id: root
    active: node != null

    required property PwNode node
    property string label: node.nickname

    sourceComponent: WrapperRectangle {
        id: comp
        color: ShellSettings.colors.surface_container_translucent
        radius: 12
        margin: 6

        border {
            width: 1
            color: ShellSettings.colors.active_translucent
        }

        // property Component button
        // property Component icon

        PwObjectTracker {
            id: tracker
            objects: [root.node]
        }

        RowLayout {
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Text {
                    text: root.label 
                    color: ShellSettings.colors.active
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                StyledSlider {
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
            }

            // StyledMouseArea {
            //     id: rightArrow
            //     Layout.preferredWidth: rightArrow.height
            //     // Layout.fillWidth: true
            //     Layout.fillHeight: true
            //
            //     IconImage {
            //         source: "root:resources/general/right-arrow.svg"
            //         anchors.fill: parent
            //     }
            // }

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
