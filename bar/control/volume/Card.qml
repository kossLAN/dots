import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import "../../.."
import "../../../widgets" as Widgets

Rectangle {
    id: root
    required property PwNode node
    required property var isSink
    color: ShellSettings.colors["surface_container_high"]

    PwObjectTracker {
        id: defaultSourceTracker
        objects: [root.node]
    }

    RowLayout {
        anchors.fill: parent
        spacing: 8

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 2
            spacing: 10

            Text {
                color: ShellSettings.colors["inverse_surface"]
                text: {

                    // Taken from quickshell-examples
                    const app = root.node?.properties["application.name"] ?? (root.node?.description != "" ? root.node?.description : root.node?.name);
                    const media = root.node?.properties["media.name"];
                    const title = media != undefined ? `${app} - ${media}` : app;

                    return title != undefined ? title : "null";
                }

                font.bold: true

                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.topMargin: 5
                Layout.rightMargin: 5
            }

            Widgets.RoundSlider {
                implicitHeight: 7
                from: 0
                to: 1
                value: root.node?.audio.volume ?? 0
                onValueChanged: root.node.audio.volume = value
                Layout.fillWidth: true
                Layout.bottomMargin: 7.5
            }
        }

        Widgets.IconButton {
            source: {
                if (!root.isSink)
                    return root.node?.audio.muted ? "root:resources/volume/microphone-mute.svg" : "root:resources/volume/microphone-full.svg";

                return root.node?.audio.muted ? "root:resources/volume/volume-mute.svg" : "root:resources/volume/volume-full.svg";
            }

            implicitSize: 36
            padding: 4
            radius: implicitSize / 2
            Layout.rightMargin: 10
            Layout.alignment: Qt.AlignLeft

            onClicked: {
                root.node.audio.muted = !root.node.audio.muted;
            }
        }
    }
}
