pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property alias settings: jsonAdapter.settings
    property alias sizing: jsonAdapter.sizing

    property QtObject colors: QtObject {
        property color surface: Qt.rgba(1.0, 1.0, 1.0, 1.0)
        property color surface_translucent: Qt.rgba(0.0, 0.0, 0.0, 0.15)
        property color surface_container: Qt.rgba(0.25, 0.25, 0.25, 1.0)
        property color surface_container_translucent: Qt.rgba(0.25, 0.25, 0.25, 0.25)
        property color highlight: Qt.rgba(1.0, 1.0, 1.0, 0.85)
        // property color primary: "#2EADC6"
        property color active: Qt.rgba(1.0, 1.0, 1.0, 1.0)
        property color active_translucent: Qt.rgba(1.0, 1.0, 1.0, 0.15)
        property color border_translucent: Qt.rgba(1.0, 1.0, 1.0, 0.05)
        property color inactive: Qt.rgba(0.25, 0.25, 0.25, 1.0)
        property color inactive_translucent: Qt.rgba(0.25, 0.25, 0.25, 0.15)
    }

    FileView {
        path: `${Quickshell.dataPath("settings")}/quickshell/settings.json`
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        blockLoading: true

        JsonAdapter {
            id: jsonAdapter

            property JsonObject settings: JsonObject {
                property string wallpaperUrl: Qt.resolvedUrl("root:resources/wallpapers/pixelart0.jpg")
                property string screenshotPath: "/home/koss/Pictures"
                property real opacity: 0.55
            }

            property JsonObject sizing: JsonObject {
                property int barHeight: 25
            }
        }
    }
}
