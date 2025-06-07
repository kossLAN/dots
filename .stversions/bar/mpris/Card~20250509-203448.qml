import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
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
                sourceSize.width: 256
                sourceSize.height: 256
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
                color: ShellGlobals.colors.text
                font.pointSize: 13
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: player.trackTitle
                color: ShellGlobals.colors.text
                font.pointSize: 13
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            RowLayout {
                spacing: 2

                Text {
                    text: timeStr(player.position)
                    color: ShellGlobals.colors.text

                    font {
                        pointSize: 9
                        bold: true
                    }
                }

                ColorQuantizer {
                    id: colorQuantizer
                    source: Qt.resolvedUrl(Media.trackedPlayer?.trackArtUrl ?? "")
                    depth: 0
                    rescaleSize: 64
                }

                Slider {
                    id: slider
                    from: 0
                    to: player.length
                    enabled: false
                    //enabled: player.canSeek
                    value: player.position

                    implicitHeight: 7
                    Layout.fillWidth: true
                    Layout.margins: 10
                    Layout.leftMargin: 5
                    Layout.rightMargin: 5
                    Layout.alignment: Qt.AlignBottom

                    background: Rectangle {
                        id: sliderContainer
                        width: slider.availableWidth
                        height: slider.implicitHeight
                        color: "white"
                        radius: 4

                        layer.enabled: true
                        layer.effect: OpacityMask {
                            source: Rectangle {
                                width: sliderContainer.width
                                height: sliderContainer.height
                                radius: sliderContainer.radius
                                color: "white"
                            }

                            maskSource: Rectangle {
                                width: sliderContainer.width
                                height: sliderContainer.height
                                radius: sliderContainer.radius
                                color: "black"
                            }
                        }

                        Rectangle {
                            id: handle
                            width: sliderContainer.width * (slider.value / slider.to)
                            height: sliderContainer.height
                            color: colorQuantizer.colors[0].darker(1.2)

                            Behavior on width {
                                NumberAnimation {
                                    duration: 100
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }
                    }

                    handle: Rectangle {
                        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                        y: slider.topPadding + slider.availableHeight / 2 - height / 2
                        width: 16
                        height: 16
                        radius: width / 2
                        color: colorQuantizer.colors[0].darker(1.4)

                        layer.enabled: true
                        layer.effect: DropShadow {
                            horizontalOffset: 0
                            verticalOffset: 1
                            radius: 4.0
                            samples: 9
                            color: "#30000000"
                        }
                    }
                }

                Text {
                    text: timeStr(player.length)
                    color: ShellGlobals.colors.text

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
                    padding: 4
                    source: "root:resources/mpris/previous.svg"
                    onClicked: player.previous()
                }

                Widgets.IconButton {
                    implicitSize: 36
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
