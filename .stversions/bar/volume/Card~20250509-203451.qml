import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import "../.."
import "../../widgets/" as Widgets

Rectangle {
    id: root
    required property PwNode node
    color: ShellGlobals.colors.light
    radius: 5

    PwObjectTracker {
        id: defaultSourceTracker
        objects: [root.node]
    }

    RowLayout {
        anchors.fill: parent
        spacing: 8

        Widgets.IconButton {
            source: {
                if (!node.properties["application.icon-name"]) {
                    return root.node.audio.muted ? "root:resources/volume/volume-mute.svg" : "root:resources/volume/volume-full.svg";
                } else {
                    return `image://icon/${node.properties["application.icon-name"]}`;
                }
            }

            implicitSize: 32
            padding: 4
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: 5

            onClicked: {
                root.node.audio.muted = !root.node.audio.muted;
            }
        }

        ColumnLayout {
            spacing: 4
            Layout.fillWidth: true
            Layout.fillHeight: true

            Text {
                color: ShellGlobals.colors.text
                text: {
                    // Taken from quickshell-examples
                    const app = node.properties["application.name"] ?? (node.description != "" ? node.description : node.name);
                    const media = node.properties["media.name"];
                    return media != undefined ? `${app} - ${media}` : app;
                }

                font.bold: true

                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.topMargin: 5
                Layout.rightMargin: 5
                Layout.bottomMargin: 5
            }

            Widgets.RoundSlider {
                implicitHeight: 7
                from: 0
                to: 1
                value: root.node.audio.volume
                onValueChanged: node.audio.volume = value
                Layout.fillWidth: true
                Layout.rightMargin: 10
                Layout.bottomMargin: 5
            }
        }
    }
}
