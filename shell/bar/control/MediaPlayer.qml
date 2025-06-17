pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.Mpris
import "../.."
import "../../widgets" as Widgets

Item {
    id: root
    required property var player
    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: root.width
            height: root.height
            radius: 14
            color: "black"
        }
    }

    ColorQuantizer {
        id: gradientQuantizer
        source: root.player?.trackArtUrl ?? ""
        depth: 2
        rescaleSize: 64
    }

    ColorQuantizer {
        id: accentQuantizer
        source: root.player?.trackArtUrl ?? ""
        depth: 0
        rescaleSize: 64
    }

    ShaderEffect {
        property color topLeftColor: gradientQuantizer?.colors[0] ?? "white"
        property color topRightColor: gradientQuantizer?.colors[1] ?? "black"
        property color bottomLeftColor: gradientQuantizer?.colors[2] ?? "white"
        property color bottomRightColor: gradientQuantizer?.colors[3] ?? "black"

        anchors.fill: parent
        fragmentShader: "root:/shaders/vertexgradient.frag.qsb"
        vertexShader: "root:/shaders/vertexgradient.vert.qsb"

        Behavior on topLeftColor {
            ColorAnimation {
                duration: 500
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on topRightColor {
            ColorAnimation {
                duration: 500
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on bottomLeftColor {
            ColorAnimation {
                duration: 500
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on bottomRightColor {
            ColorAnimation {
                duration: 500
                easing.type: Easing.InOutQuad
            }
        }
    }

    RowLayout {
        id: cardLayout
        spacing: 15

        anchors {
            fill: parent
            margins: 10
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 5

            RowLayout {
                Rectangle {
                    id: mprisImage
                    color: "transparent"
                    radius: 10
                    width: 50
                    height: 50
                    Layout.alignment: Qt.AlignVCenter
                    visible: true

                    layer.enabled: true
                    layer.effect: DropShadow {
                        transparentBorder: true
                        spread: 0.02
                        samples: 25
                        color: "#80000000"
                    }

                    Image {
                        anchors.fill: parent
                        source: root.player?.trackArtUrl ?? ""
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
                        }
                    }
                }

                ColumnLayout {
                    Layout.leftMargin: 7.5
                    Layout.alignment: Qt.AlignBottom

                    Text {
                        text: root.player?.trackArtist ?? "NA"
                        color: "white"
                        font.pointSize: 13
                        font.bold: true
                        horizontalAlignment: Text.AlignLeft
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Text {
                        text: root.player?.trackTitle ?? "NA"
                        color: "white"
                        font.pointSize: 13
                        horizontalAlignment: Text.AlignLeft
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }
            }

            RowLayout {
                spacing: 6

                Text {
                    text: timeStr(root.player?.position)
                    color: "white"

                    font {
                        pointSize: 9
                        bold: true
                    }
                }

                FrameAnimation {
                    running: root.player?.playbackState == MprisPlaybackState.Playing
                    onTriggered: root.player?.positionChanged()
                }

                Widgets.RoundSlider {
                    id: positionSlider
                    implicitHeight: 7
                    from: 0
                    to: root.player?.length
                    accentColor: accentQuantizer.colors[0]?.darker(1.2) ?? "purple"
                    value: root.player?.position ?? 0
                    Layout.fillWidth: true

                    onMoved: {
                        if (root.player == null)
                            return;

                        root.player.position = value;
                    }
                }

                Text {
                    text: timeStr(root.player?.length)
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
                    implicitSize: 40
                    activeRectangle: false
                    padding: 4
                    source: "root:resources/mpris/previous.svg"
                    onClicked: root.player?.previous()
                }

                Widgets.IconButton {
                    implicitSize: 40
                    activeRectangle: false
                    padding: 4
                    source: root.player?.isPlaying ? "root:resources/mpris/pause.svg" : "root:resources/mpris/play.svg"
                    onClicked: {
                        if (!root.player?.canPlay)
                            return;
                        player.isPlaying ? player.pause() : player.play();
                    }
                }

                Widgets.IconButton {
                    implicitSize: 40
                    activeRectangle: false
                    padding: 4
                    source: "root:resources/mpris/next.svg"
                    onClicked: root.player?.next()
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
