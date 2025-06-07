pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME")
    readonly property string folderName: "kdots"

    readonly property string settingsPath: `${configHome}/${folderName}/settings.json`
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
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: writeAdapter()
        blockLoading: true

        JsonAdapter {
            id: userAdapter

            property JsonObject settings: JsonObject {
                property string wallpaperUrl: Qt.resolvedUrl("root:resources/wallpapers/wallhaven-96y9qk.jpg")
                property string wallpapersPath: `${root.homeDir}/Pictures/Wallpapers`
                property string wallpaperTransition: "circle" // circle, fade, slide, pixelate, dissolve

                property bool bluetoothEnabled: true
                property bool searchEnabled: true 
                property bool debugEnabled: true 
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
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: writeAdapter()
        blockLoading: true

        JsonAdapter {
            id: systemAdapter

            property var outputs: ({})
        }
    }
}
