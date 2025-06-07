pragma Singleton

import QtQuick
import Quickshell

Singleton {
    SystemPalette {
        id: activePalette
        colorGroup: SystemPalette.Active
    }

    readonly property var colors: QtObject {
        readonly property color accent: "lightblue"
        //readonly property color accent: "#5AA097"
        readonly property color base: "#161616"
        readonly property color mid: "#1E1F1F"
        readonly property color light: "#353636"
        //readonly property color button: activePalette.button
        //readonly property color buttonText: activePalette.button
        //readonly property color dark: activePalette.dark
        readonly property color highlight: activePalette.highlight
        //readonly property color textHighlight: activePalette.highlightedText
        //readonly property color light: activePalette.light
        //readonly property color mid: activePalette.mid
        readonly property color midlight: activePalette.midlight
        readonly property color text: activePalette.text
        //readonly property color window: activePalette.window
        //readonly property color innerHighlight: "#416563"

        //readonly property color accent: "#5AA097"
    }
}
