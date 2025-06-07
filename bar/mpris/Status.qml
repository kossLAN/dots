import QtQuick
import Quickshell.Widgets
import Quickshell.Services.Mpris
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
