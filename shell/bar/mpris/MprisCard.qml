pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.Mpris

import qs.widgets

Loader {
    id: root

    required property MprisPlayer player
    property int currentIndex: 0
    property int totalCount: 1
    property var colors: []

    // Since we are using colorQuantizer to get colors to use in the background,
    // we can end up in situations where the foreground elements do not constrast well.
    // This is a luminance equation I ripped from the internet to help contrast elements. Not a perfect solution, but better than not being able to read elements.
    readonly property bool isLightBackground: {
        if (!colors || colors.length < 4)
            return false;

        const c0 = colors[0], c1 = colors[1], c2 = colors[2], c3 = colors[3];

        if (!c0 || !c1 || !c2 || !c3)
            return false;

        const avgR = (c0.r + c1.r + c2.r + c3.r) / 4;
        const avgG = (c0.g + c1.g + c2.g + c3.g) / 4;
        const avgB = (c0.b + c1.b + c2.b + c3.b) / 4;
        const luminance = 0.299 * avgR + 0.587 * avgG + 0.114 * avgB;

        return luminance > 0.5;
    }

    readonly property color accentColor: {
        if (!colors || colors.length < 5 || !colors[4])
            return Qt.color("purple");

        // Use color[4] for accent (different from text which uses color[6])
        let accent = colors[4];
        let accentLum = 0.299 * accent.r + 0.587 * accent.g + 0.114 * accent.b;

        if (isLightBackground) {
            // For light bg, want a rich saturated accent in mid-dark range
            if (accentLum > 0.5) {
                return Qt.darker(accent, 2.0);
            }
            return Qt.darker(accent, 1.4);
        } else {
            // For dark bg, want accent to be vibrant but not white
            // Keep it in the mid-brightness range (0.4-0.7) so it stands out from white text
            if (accentLum < 0.25) {
                return Qt.lighter(accent, 2.2);
            } else if (accentLum > 0.7) {
                return Qt.darker(accent, 1.5);
            }
            return Qt.lighter(accent, 1.5);
        }
    }

    readonly property color railColor: {
        if (isLightBackground) {
            return Qt.rgba(0, 0, 0, 0.55);
        }

        return Qt.rgba(1, 1, 1, 0.35);
    }

    readonly property color textColor: {
        if (!colors || colors.length < 7 || !colors[6])
            return isLightBackground ? Qt.rgba(0, 0, 0, 0.85) : Qt.rgba(1, 1, 1, 0.95);

        // Use a quantizer color as base
        let baseColor = colors[6];
        let baseLuminance = 0.299 * baseColor.r + 0.587 * baseColor.g + 0.114 * baseColor.b;

        if (isLightBackground) {
            let darkened = Qt.darker(baseColor, 1.5);
            let darkLum = 0.299 * darkened.r + 0.587 * darkened.g + 0.114 * darkened.b;

            // If still too light, blend with black
            if (darkLum > 0.3) {
                return Qt.rgba(darkened.r * 0.3, darkened.g * 0.3, darkened.b * 0.3, 0.9);
            }

            return Qt.rgba(darkened.r, darkened.g, darkened.b, 0.9);
        } else {
            let lightened = Qt.lighter(baseColor, 2.0);
            let lightLum = 0.299 * lightened.r + 0.587 * lightened.g + 0.114 * lightened.b;

            // If still too dark, blend with white
            if (lightLum < 0.7) {
                return Qt.rgba(0.7 + lightened.r * 0.3, 0.7 + lightened.g * 0.3, 0.7 + lightened.b * 0.3, 0.95);
            }

            return Qt.rgba(lightened.r, lightened.g, lightened.b, 0.95);
        }
    }

    active: player !== null

    sourceComponent: RowLayout {
        id: component
        width: root.width
        height: root.height
        spacing: 20
        anchors.margins: 8

        Item {
            Layout.preferredWidth: height
            Layout.fillHeight: true
            Layout.leftMargin: 16
            Layout.topMargin: 16
            Layout.bottomMargin: 16

            RectangularShadow {
                anchors.fill: albumArt
                radius: 8
                blur: 16
                spread: 2
                offset: Qt.vector2d(0, 4)
                color: Qt.rgba(0, 0, 0, 0.5)
            }

            Image {
                id: albumArt
                source: Qt.resolvedUrl(root.player?.trackArtUrl ?? "")
                fillMode: Image.PreserveAspectCrop

                sourceSize {
                    width: 256
                    height: 256
                }

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: albumArt.width
                        height: albumArt.height
                        radius: 8
                        color: "black"
                    }
                }

                anchors.fill: parent
            }
        }

        // Track info and controls container
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.rightMargin: 12

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width
                spacing: 6

                StyledText {
                    text: root.player?.trackTitle || "Unknown Title"
                    font.bold: true
                    font.pointSize: 11
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    textColor: root.textColor

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                }

                StyledText {
                    textColor: root.textColor
                    opacity: 0.7
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: 9

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter

                    text: {
                        const artist = root.player?.trackArtist || "Unknown Artist";
                        const album = root.player?.trackAlbum || "";
                        return album ? artist + " - " + album : artist;
                    }
                }

                RowLayout {
                    spacing: 8
                    Layout.fillWidth: true
                    Layout.topMargin: 4

                    StyledText {
                        text: component.formatTime(root.player?.position ?? 0)
                        font.pointSize: 8
                        opacity: 0.7
                        textColor: root.textColor
                    }

                    StyledSlider {
                        id: progressSlider
                        enabled: root.player?.canSeek ?? false
                        value: root.player?.position ?? 0
                        from: 0
                        to: root.player?.length ?? 1

                        accentColor: root.accentColor
                        railColor: root.railColor

                        Layout.fillWidth: true

                        onMoved: {
                            if (root.player?.canSeek) {
                                root.player.position = value;
                            }
                        }
                    }

                    StyledText {
                        text: component.formatTime(root.player?.length ?? 0)
                        font.pointSize: 8
                        opacity: 0.7
                        textColor: root.textColor
                    }
                }

                RowLayout {
                    spacing: 16
                    Layout.alignment: Qt.AlignHCenter

                    IconButton {
                        hoverColor: root.accentColor
                        iconColor: root.textColor
                        source: Quickshell.iconPath("media-playlist-shuffle")
                        implicitSize: 18
                        opacity: root.player?.shuffle ? 1.0 : 0.4
                        visible: root.player?.shuffleSupported ?? false
                        onClicked: {
                            if (root.player?.canControl && root.player?.shuffleSupported) {
                                root.player.shuffle = !root.player.shuffle;
                            }
                        }
                    }

                    IconButton {
                        hoverColor: root.accentColor
                        iconColor: root.textColor
                        source: Quickshell.iconPath("media-skip-backward")
                        implicitSize: 24
                        opacity: root.player?.canGoPrevious ? 1.0 : 0.4
                        onClicked: {
                            if (root.player?.canGoPrevious) {
                                root.player.previous();
                            }
                        }
                    }

                    IconButton {
                        hoverColor: root.accentColor
                        iconColor: root.textColor
                        source: Quickshell.iconPath(root.player?.isPlaying ? "media-playback-pause" : "media-playback-start")
                        implicitSize: 32
                        opacity: root.player?.canTogglePlaying ? 1.0 : 0.4
                        onClicked: {
                            if (root.player?.canTogglePlaying) {
                                root.player.togglePlaying();
                            }
                        }
                    }

                    IconButton {
                        hoverColor: root.accentColor
                        iconColor: root.textColor
                        source: Quickshell.iconPath("media-skip-forward")
                        implicitSize: 24
                        opacity: root.player?.canGoNext ? 1.0 : 0.4
                        onClicked: {
                            if (root.player?.canGoNext) {
                                root.player.next();
                            }
                        }
                    }

                    IconButton {
                        hoverColor: root.accentColor
                        iconColor: root.textColor
                        implicitSize: 18
                        opacity: root.player?.loopState !== MprisLoopState.None ? 1.0 : 0.4
                        visible: root.player?.loopSupported ?? false

                        source: {
                            if (root.player?.loopState === MprisLoopState.Track) {
                                return Quickshell.iconPath("media-playlist-repeat-song");
                            }

                            return Quickshell.iconPath("media-playlist-repeat");
                        }

                        onClicked: {
                            if (root.player?.canControl && root.player?.loopSupported) {
                                if (root.player.loopState === MprisLoopState.None) {
                                    root.player.loopState = MprisLoopState.Playlist;
                                } else if (root.player.loopState === MprisLoopState.Playlist) {
                                    root.player.loopState = MprisLoopState.Track;
                                } else {
                                    root.player.loopState = MprisLoopState.None;
                                }
                            }
                        }
                    }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                spacing: 6
                visible: root.totalCount > 1

                Repeater {
                    model: root.totalCount

                    Rectangle {
                        required property int index

                        width: 6
                        height: 6
                        radius: 3
                        color: {
                            if (index === root.currentIndex)
                                return root.accentColor;
                            else
                                return root.railColor;
                        }
                    }
                }
            }
        }

        // Update position periodically when playing
        Timer {
            running: root.player?.playbackState === MprisPlaybackState.Playing
            interval: 1000
            repeat: true
            onTriggered: root.player?.positionChanged()
        }

        function formatTime(seconds: real): string {
            const mins = Math.floor(seconds / 60);
            const secs = Math.floor(seconds % 60);
            return mins + ":" + (secs < 10 ? "0" : "") + secs;
        }
    }
}
