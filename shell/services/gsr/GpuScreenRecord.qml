pragma Singleton

import Quickshell
import Quickshell.Io

import qs

Singleton {
    id: root

    readonly property string configPath: `${ShellSettings.folderPath}/gpuscreenrecord.json`

    FileView {
        id: userFile
        path: root.configPath
        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: userAdapter

            property JsonObject settings: JsonObject {
                property string wallpaperUrl: ""
                property string wallpapersPath: `${root.homeDir}/.wallpapers`
                property string wallpaperTransition: "circle" // circle, fade, slide, pixelate, dissolve

                property bool bluetoothEnabled: true
                property bool searchEnabled: true
                property bool debugEnabled: true
            }

            property JsonObject gsr: JsonObject {
                property int fps: 60
                property int replayBufferSize: 30 // 30 secs
            }

            property JsonObject sizing: JsonObject {
                property int barHeight: 25
            }
        }
    }
}
