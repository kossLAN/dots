pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property alias settings: jsonAdapter.settings
    property alias sizing: jsonAdapter.sizing

    property QtObject colors: QtObject {
        // Background colors - for surfaces and overlays
        property color background: Qt.rgba(0.0, 0.0, 0.0, 0.15)

        // Foreground colors - for text, icons, and UI elements
        property color foreground: Qt.rgba(1.0, 1.0, 1.0, 1.0)
        property color foregroundDim: Qt.rgba(0.25, 0.25, 0.25, 1.0)

        // Accent & highlight colors - for interactive and focused elements
        property color accent: Qt.rgba(1.0, 1.0, 1.0, 0.15)
        property color highlight: Qt.rgba(1.0, 1.0, 1.0, 0.85)
        property color trim: Qt.rgba(1.0, 1.0, 1.0, 0.15)

        // Border colors
        property color border: Qt.rgba(1.0, 1.0, 1.0, 1.0)
        property color borderSubtle: Qt.rgba(1.0, 1.0, 1.0, 0.05)

        // Legacy compatibility aliases (deprecated - use new names above)
        property color surface: background
        property color surface_translucent: background
        property color surface_container: background
        property color surface_container_translucent: background
        property color active: foreground
        property color active_translucent: trim 
        property color inactive: foregroundDim
        property color inactive_translucent: foregroundDim
        property color border_translucent: borderSubtle
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
