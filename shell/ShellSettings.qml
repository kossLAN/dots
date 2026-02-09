pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME")
    readonly property string folderName: "nixi"
    readonly property string folderPath: `${configHome}/${folderName}`

    readonly property string settingsPath: `${folderPath}/settings.json`
    readonly property string systemSettingsPath: `/etc/${folderName}/settings.json`

    property alias settings: userAdapter.settings
    property alias sizing: userAdapter.sizing
    property alias outputs: systemAdapter.outputs

    property QtObject colors: QtObject {
        property SystemPalette active: SystemPalette {
            colorGroup: SystemPalette.Active
        }

        property SystemPalette inactive: SystemPalette {
            colorGroup: SystemPalette.Inactive
        }
    }

    FileView {
        id: userFile
        path: root.settingsPath
        onAdapterUpdated: writeAdapter()
        blockLoading: true

        JsonAdapter {
            id: userAdapter

            property JsonObject settings: JsonObject {
                property string wallpaperUrl: "" 
                property string wallpapersPath: `${root.homeDir}/.wallpapers`
                property string wallpaperTransition: "circle" // circle, fade, slide, pixelate, dissolve

                property bool bluetoothEnabled: true
                property bool searchEnabled: true
                property bool debugEnabled: true
                property bool gsrEnabled: true
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

    FileView {
        id: systemFile
        path: root.systemSettingsPath
        watchChanges: true
        onAdapterUpdated: writeAdapter()
        // onLoadFailed: writeAdapter()
        blockLoading: true

        JsonAdapter {
            id: systemAdapter

            property var outputs: ({})
        }
    }
}
