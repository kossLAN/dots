pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string homeDir: Quickshell.env("HOME") || ""
    readonly property string settingsDir: `${Quickshell.env("XDG_CONFIG_HOME")}/kdots`
    readonly property string settingsPath: `${settingsDir}/settings.json`

    property alias settings: jsonAdapter.settings
    property alias sizing: jsonAdapter.sizing
    property alias colors: jsonAdapter.colors
    property alias colorPresets: jsonAdapter.colorPresets

    FileView {
        id: settingsFile
        path: root.settingsPath
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        blockLoading: true

        Component.onCompleted: writeAdapter() 

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

            property JsonObject colors: JsonObject {
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
            }

            property var colorPresets: [
                ({
                    id: "default_glass",
                    name: "Default Glass",
                    description: "Current frosted glass palette",
                    colors: {
                        background: "#26000000",
                        foreground: "#FFFFFFFF",
                        foregroundDim: "#FF404040",
                        accent: "#26FFFFFF",
                        highlight: "#D9FFFFFF",
                        trim: "#26FFFFFF",
                        border: "#FFFFFFFF",
                        borderSubtle: "#0DFFFFFF"
                    }
                }),
                ({
                    id: "midnight_neon",
                    name: "Midnight Neon",
                    description: "Deep blues with neon trims",
                    colors: {
                        background: "#04091F66",
                        foreground: "#E2E8FFFF",
                        foregroundDim: "#4C5977FF",
                        accent: "#1D9BF080",
                        highlight: "#64B5F6CC",
                        trim: "#0FF4F880",
                        border: "#4FC3F7FF",
                        borderSubtle: "#4FC3F726"
                    }
                }),
                ({
                    id: "sunset_punch",
                    name: "Sunset Punch",
                    description: "Warm oranges with magenta pops",
                    colors: {
                        background: "#2B0B1666",
                        foreground: "#FFE5D9FF",
                        foregroundDim: "#AD6F6FFF",
                        accent: "#FF7A004D",
                        highlight: "#FFB347CC",
                        trim: "#FF4D6D80",
                        border: "#FFB347FF",
                        borderSubtle: "#FFB34726"
                    }
                }),
                ({
                    id: "forest_mist",
                    name: "Forest Mist",
                    description: "Mossy greens with cool accents",
                    colors: {
                        background: "#041F1B66",
                        foreground: "#E5FFFBFF",
                        foregroundDim: "#7DA69DFF",
                        accent: "#4CAF5054",
                        highlight: "#9CFFC8CC",
                        trim: "#00BFA580",
                        border: "#9CFFC8FF",
                        borderSubtle: "#9CFFC826"
                    }
                })
            ]
        }
    }
}
