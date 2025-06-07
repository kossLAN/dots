import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import "../.."
import "../../widgets" as Widgets

Rectangle {
    required property var player

    radius: 5
    color: "transparent"
    implicitHeight: 220

    RowLayout {
        id: cardLayout
        spacing: 15

        anchors {
            fill: parent
            leftMargin: 10
            rightMargin: 10
            topMargin: 10 // Added top margin for better spacing
            bottomMargin: 10 // Added bottom margin for better spacing
        }

        Rectangle {
            id: mprisImage
            color: "transparent"
            radius: 10
            width: 200
            height: 200
            Layout.alignment: Qt.AlignVCenter
            visible: true

            Image {
                anchors.fill: parent
                source: player.trackArtUrl
                sourceSize.width: 1024
                sourceSize.height: 1024
                fillMode: Image.PreserveAspectFit

                layer.enabled: true
                layer.effect: OpacityMask {
                    source: Rectangle {
                        width: mprisImage.width
                        height: mprisImage.height
                        radius: 10
                        color: "white"
                    }

                    maskSource: Rectangle {
                        width: mprisImage.width
                        height: mprisImage.height
                        radius: 10
                        color: "black"
                    }

                    layer.enabled: true
                    layer.effect: DropShadow {
                        transparentBorder: true
                        spread: 0.02
                        samples: 25
                        color: "#80000000"
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 5

            Text {
                text: player.trackArtist
                color: "white"
                font.pointSize: 13
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: player.trackTitle
                color: "white"
                font.pointSize: 13
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            RowLayout {
                spacing: 6

                ColorQuantizer {
                    id: colorQuantizer
                    source: Qt.resolvedUrl(Media.trackedPlayer?.trackArtUrl ?? "")
                    depth: 0
                    rescaleSize: 64
                }

                Text {
                    text: timeStr(player.position)
                    color: "white"

                    font {
                        pointSize: 9
                        bold: true
                    }
                }

                Widgets.RoundSlider {
                    from: 0
                    to: 1
                    accentColor: colorQuantizer.colors[0]
                    //value: root.node.audio.volume
                    //onValueChanged: node.audio.volume = value
                    Layout.fillWidth: true
                    Layout.preferredHeight: 16
                }

                Text {
                    text: timeStr(player.length)
                    color: "white"

                    font {
                        pointSize: 9
                        bold: true
                    }
                }
            }

            // Music Controls
            RowLayout {
                spacing: 2
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                Widgets.IconButton {
                    implicitSize: 36
                    activeRectangle: false
                    padding: 4
                    source: "root:resources/mpris/previous.svg"
                    onClicked: player.previous()
                }

                Widgets.IconButton {
                    implicitSize: 36
                    activeRectangle: false
                    padding: 4
                    source: player?.isPlaying ? "root:resources/mpris/pause.svg" : "root:resources/mpris/play.svg"
                    onClicked: {
                        if (!player.canPlay)
                            return;
                        player.isPlaying ? player.pause() : player.play();
                    }
                }

                Widgets.IconButton {
                    implicitSize: 36
                    activeRectangle: false
                    padding: 4
                    source: "root:resources/mpris/next.svg"
                    onClicked: player.next()
                }
            }
        }
    }

    function timeStr(time: int): string {
        const seconds = time % 60;
        const minutes = Math.floor(time / 60);

        return `${minutes}:${seconds.toString().padStart(2, '0')}`;
    }
}
