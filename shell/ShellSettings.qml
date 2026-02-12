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

        property QtObject extra: QtObject {
            property color open: Qt.color("#4ade80") 
            property color close: Qt.color("#FF474D") 
        }
    }

    FileView {
        id: userFile
        path: root.settingsPath
        blockLoading: true
        onAdapterUpdated: writeAdapter()
        onLoadFailed: (error) => {
            if (error === FileViewError.FileNotFound)
                writeAdapter();
        }

        JsonAdapter {
            id: userAdapter

            property JsonObject settings: JsonObject {
                property string wallpaperUrl: "" 
                property string wallpapersPath: `${root.homeDir}/.wallpapers`

                property bool bluetoothEnabled: true
                property bool searchEnabled: true
                property bool debugEnabled: true
                property bool gsrEnabled: true
                property bool chatEnabled: true
            }

            property JsonObject sizing: JsonObject {
                property int barHeight: 25

                property JsonObject launcherPosition: JsonObject {
                    property real centerX: -1
                    property real y: -1
                }

                property JsonObject chatSize: JsonObject {
                    property real width: 950
                    property real height: 600
                }
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
