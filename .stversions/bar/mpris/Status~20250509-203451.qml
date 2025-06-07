import QtQuick
import Quickshell.Widgets
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects
import "../.."

Item {
    id: root
    required property var bar

    width: statusInfo.width + 125
    height: parent.height
    visible: Mpris.players.values.length != 0 
    
    Player {
        id: mediaPlayer
        anchor.window: bar
        anchor.rect.x: parentWindow.width / 2 - width / 2
        anchor.rect.y: parentWindow.height
    }

    MouseArea {
        id: playButton
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                if (mediaPlayer.visible) {
                    mediaPlayer.hide();
                } else {
                    mediaPlayer.show();
                }
            } else {
                if (!Media.trackedPlayer.canPlay || Media.trackedPlayer == null)
                    return;

                if (Media.trackedPlayer.isPlaying)
                    Media.trackedPlayer.pause();
                else
                    Media.trackedPlayer.play();
            }
        }

        anchors.fill: parent
    }

    ShaderEffect {
        id: gradientShader
        property color topLeftColor: Media?.colors[0] ?? "white"
        property color topRightColor: Media?.colors[1] ?? "black"
        property color bottomLeftColor: Media?.colors[2] ?? "white"
        property color bottomRightColor: Media?.colors[3] ?? "black"
        anchors.fill: parent
        visible: false
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

    Rectangle {
        id: artRect
        anchors.fill: gradientShader
        antialiasing: true
        visible: false
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: "transparent"
            }
            GradientStop {
                position: 0.5
                color: "white"
            }
            GradientStop {
                position: 1.0
                color: "transparent"
            }
        }
    }

    OpacityMask {
        id: clip
        source: gradientShader
        anchors.fill: gradientShader
        maskSource: artRect
        cached: false
        visible: false
    }

    GaussianBlur {
        id: blur
        visible: root.visible
        source: clip
        anchors.fill: clip
        radius: 16
        samples: radius * 2
        transparentBorder: true
    }

    Item {
        id: statusInfo
        width: statusIcon.width + statusIcon.anchors.rightMargin + nowPlayingText.width
        height: parent.height
        visible: Media.trackedPlayer != null

        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
            top: parent.top
            bottom: parent.botton
            margins: 3.5
        }

        //Rectangle {
        //    color: ShellGlobals.colors.accent
        //    radius: 3
        //    width: parent.width + 25
        //    height: parent.height - 7
        //    visible: playButton.containsMouse
        //    anchors.centerIn: parent
        //}

        IconImage {
            id: statusIcon
            implicitSize: 13
            source: Media.trackedPlayer?.isPlaying ? "root:resources/mpris/pause.svg" : "root:resources/mpris/play.svg"

            anchors {
                verticalCenter: parent.verticalCenter
                right: nowPlayingText.left
                rightMargin: 10
            }
        }

        Text {
            id: nowPlayingText
            color: ShellGlobals.colors.text
            text: `${Media.trackedPlayer?.trackArtist} - ${Media.trackedPlayer?.trackTitle}`
            font.pointSize: 11
            width: Math.min(implicitWidth, 250)
            elide: Text.ElideRight

            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
            }
        }
    }
}
