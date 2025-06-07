pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland

import qs
import qs.bar
import qs.widgets
import qs.services.mpris

StyledMouseArea {
    id: root

    required property var bar
    property bool showMenu: false

    property string activeTitle: Mpris.trackedPlayer?.trackTitle ?? ""
    property string displayedTitle: activeTitle
    property bool isPlaying: Mpris.trackedPlayer?.isPlaying ?? false
    property bool displayedIsPlaying: isPlaying

    visible: Mpris.trackedPlayer !== null
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    implicitWidth: contentRow.implicitWidth + 8
    implicitHeight: contentRow.implicitHeight

    onActiveTitleChanged: fadeOut.start()
    onIsPlayingChanged: fadeOut.start()

    onClicked: event => {
        if (event.button == Qt.LeftButton) {
            showMenu = !showMenu;
        } else if (event.button == Qt.RightButton) {
            if (!Mpris.trackedPlayer)
                return;

            if (Mpris.trackedPlayer.isPlaying)
                Mpris.trackedPlayer.pause();
            else
                Mpris.trackedPlayer.play();
        }
    }

    NumberAnimation {
        id: fadeOut
        target: contentRow
        property: "opacity"
        to: 0
        duration: 100

        onFinished: {
            root.displayedTitle = root.activeTitle;
            root.displayedIsPlaying = root.isPlaying;
            fadeIn.start();
        }
    }

    NumberAnimation {
        id: fadeIn
        target: contentRow
        property: "opacity"
        to: 1
        duration: 100
    }

    RowLayout {
        id: contentRow
        spacing: 5

        anchors {
            fill: parent
            leftMargin: 4
            rightMargin: 4
        }

        IconImage {
            id: playIcon
            Layout.preferredWidth: root.height
            Layout.preferredHeight: root.height
            source: Quickshell.iconPath(root.displayedIsPlaying ? "media-pause" : "media-play")
        }

        Text {
            id: windowText
            text: root.displayedTitle
            color: ShellSettings.colors.active.windowText
            font.pointSize: 11
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }
    }

    // GET RID OF THIS WHENEVER POSSIBLE ITS BAD!
    CachedImage {
        id: artCache

        source: {
            const idx = players.currentIndex;

            if (idx >= 0 && idx < Mpris.sortedPlayers.length) {
                return Mpris.sortedPlayers[idx]?.trackArtUrl ?? "";
            }

            return "";
        }
    }

    ColorQuantizer {
        id: colorQuantizer
        source: artCache.ready ? artCache.cachedSource : ""
        depth: 3
        rescaleSize: 64
    }

    property PopupItem menu: PopupItem {
        id: menu
        owner: root
        popup: root.bar.popup
        show: root.showMenu
        centered: true
        onClosed: root.showMenu = false

        implicitWidth: 525
        implicitHeight: 150

        backgroundComponent: ClippingRectangle {
            clip: true
            color: "transparent"
            radius: 12
            contentUnderBorder: true

            ShaderEffect {
                fragmentShader: "root:resources/shaders/vertexgradient.frag.qsb"
                vertexShader: "root:resources/shaders/vertexgradient.vert.qsb"
                anchors.fill: parent

                property color topLeftColor: colorQuantizer.colors[0] ?? Qt.rgba(0, 0, 0, 1)
                property color topCenterColor: colorQuantizer.colors[1] ?? Qt.rgba(0, 0, 0, 1)
                property color topRightColor: colorQuantizer.colors[2] ?? Qt.rgba(0, 0, 0, 1)
                property color middleLeftColor: colorQuantizer.colors[3] ?? Qt.rgba(0, 0, 0, 1)
                property color middleRightColor: colorQuantizer.colors[4] ?? Qt.rgba(0, 0, 0, 1)
                property color bottomLeftColor: colorQuantizer.colors[5] ?? Qt.rgba(0, 0, 0, 1)
                property color bottomCenterColor: colorQuantizer.colors[6] ?? Qt.rgba(0, 0, 0, 1)
                property color bottomRightColor: colorQuantizer.colors[7] ?? Qt.rgba(0, 0, 0, 1)

                Behavior on topLeftColor {
                    ColorAnimation {
                        duration: 300
                    }
                }

                Behavior on topCenterColor {
                    ColorAnimation {
                        duration: 300
                    }
                }

                Behavior on topRightColor {
                    ColorAnimation {
                        duration: 300
                    }
                }

                Behavior on middleLeftColor {
                    ColorAnimation {
                        duration: 300
                    }
                }

                Behavior on middleRightColor {
                    ColorAnimation {
                        duration: 300
                    }
                }

                Behavior on bottomLeftColor {
                    ColorAnimation {
                        duration: 300
                    }
                }

                Behavior on bottomCenterColor {
                    ColorAnimation {
                        duration: 300
                    }
                }

                Behavior on bottomRightColor {
                    ColorAnimation {
                        duration: 300
                    }
                }
            }

            Rectangle {
                color: "black"
                opacity: 0.1
                anchors.fill: parent
            }
        }

        StyledListView {
            id: players
            spacing: 0
            orientation: ListView.Horizontal
            snapMode: ListView.SnapOneItem
            highlightRangeMode: ListView.StrictlyEnforceRange
            clip: false

            anchors.fill: parent

            model: Mpris.sortedPlayers

            delegate: MprisCard {
                required property var modelData
                required property int index

                player: modelData
                currentIndex: index
                totalCount: players.count
                width: players.width
                height: players.height
                colors: colorQuantizer.colors
            }
        }
    }
}
