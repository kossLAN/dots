pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs

Variants {
    id: root

    model: Quickshell.screens

    PanelWindow {
        required property var modelData

        color: "transparent"
        aboveWindows: false
        screen: modelData

        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "shell:overview"

        anchors {
            left: true
            right: true
            top: true
            bottom: true
        }

        ShaderEffect {
            fragmentShader: "root:resources/shaders/vertexgradient.frag.qsb"
            vertexShader: "root:resources/shaders/vertexgradient.vert.qsb"
            anchors.fill: parent

            property color topLeftColor: colorQuantizer.colors[0] ?? Qt.rgba(0, 0, 0, 1)
            property color topCenterColor: colorQuantizer.colors[1] ?? Qt.rgba(0, 0, 0, 1)
            property color topRightColor: colorQuantizer.colors[2] ?? Qt.rgba(0, 0, 0, 1)
            property color middleLeftColor: colorQuantizer.colors[3] ?? Qt.rgba(0, 0, 0, 1)
            property color middleRightColor: colorQuantizer.colors[4] ?? Qt.rgba(0, 0, 0, 1)
            property color bottomLeftColor: colorQuantizer.colors[5] ?? Qt.rgba(0, 0, 0, 1)
            property color bottomCenterColor: colorQuantizer.colors[6] ?? Qt.rgba(0, 0, 0, 1)
            property color bottomRightColor: colorQuantizer.colors[7] ?? Qt.rgba(0, 0, 0, 1)
        }

        // Gotta make good use of this somehow
        ColorQuantizer {
            id: colorQuantizer
            source: ShellSettings.settings.wallpaperUrl
            depth: 3
            rescaleSize: 64
        }
    }
}
