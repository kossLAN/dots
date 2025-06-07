pragma Singleton

import QtQuick
import Quickshell

Singleton {
  SystemPalette { id: activePalette; colorGroup: SystemPalette.Active }

  readonly property var colors: QtObject {
    readonly property color accent: activePalette.accent;
    readonly property color alternateBase: activePalette.alternateBase;
    readonly property color base: activePalette.base;
    readonly property color button: activePalette.button; 
    readonly property color buttonText: activePalette.button;
    readonly property color dark: activePalette.dark;
    readonly property color highlight: activePalette.highlight;
    readonly property color textHighlight: activePalette.highlightedText;
    readonly property color light: activePalette.light;
    readonly property color mid: activePalette.mid; 
    readonly property color midlight: activePalette.midlight; 
    readonly property color shadow: activePalette.shadow;
    readonly property color text: activePalette.text;
    readonly property color window: activePalette.window; 
    readonly property color windowText: activePalette.windowText; 
    readonly property color innerHighlight: "#416563";
  }
}
