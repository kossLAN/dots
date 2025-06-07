pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Singleton {
    id: root

    property MprisPlayer trackedPlayer

    property list<MprisPlayer> sortedPlayers: [...Mpris.players.values].sort((a, b) => {
        if (a === root.trackedPlayer)
            return -1;

        if (b === root.trackedPlayer)
            return 1;

        return 0;
    })

    IpcHandler {
        target: "mpris"

        function next(): void {
            root.trackedPlayer.next();
        }

        function prev(): void {
            root.trackedPlayer.previous();
        }

        function play(): void {
            root.trackedPlayer.play();
        }

        function pause(): void {
            root.trackedPlayer.pause();
        }

        function play_pause(): void {
            if (root.trackedPlayer.isPlaying) {
                root.trackedPlayer.pause();
            } else {
                root.trackedPlayer.play();
            }
        }
    }

    Instantiator {
        model: Mpris.players

        Connections {
            required property MprisPlayer modelData
            target: modelData

            Component.onCompleted: {
                if (root.trackedPlayer == null || modelData.isPlaying) {
                    root.trackedPlayer = modelData;
                }
            }

            Component.onDestruction: {
                if (root.trackedPlayer == null || !root.trackedPlayer.isPlaying) {
                    for (const player of Mpris.players.values) {
                        if (player.playbackState === MprisPlaybackState.Playing) {
                            root.trackedPlayer = player;
                            break;
                        }
                    }

                    if (root.trackedPlayer == null && Mpris.players.values.length != 0) {
                        root.trackedPlayer = Mpris.players.values[0];
                    }
                }
            }

            function onPlaybackStateChanged() {
                if (root.trackedPlayer !== modelData)
                    root.trackedPlayer = modelData;
            }
        }
    }

    function init() {
    }
}
