pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import qs.widgets
import qs

Loader {
    id: root
    active: node != null

    required property PwNode node
    property string label: node.nickname ?? node.name

    property Component leftWidget

    PwObjectTracker {
        id: tracker
        objects: [root.node]
    }

    sourceComponent: WrapperItem {
        margin: 6

        RowLayout {
            spacing: 10

            Loader {
                id: leftWidget
                sourceComponent: root.leftWidget
                Layout.preferredWidth: this.height
                Layout.fillHeight: true
            }

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
        }
    }
}
