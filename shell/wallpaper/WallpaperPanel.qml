pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import qs

Variants {
    id: root

    model: Quickshell.screens

    PanelWindow {
        id: panel
        required property var modelData

        color: "transparent"
        aboveWindows: false
        screen: modelData

        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "shell:wallpaper"

        anchors {
            left: true
            right: true
            top: true
            bottom: true
        }

        property string currentWallpaper
        property string previousWallpaper
        property real transitionProgress: 1.0

        Component.onCompleted: {
            currentWallpaper = ShellSettings.settings.wallpaperUrl;
            previousWallpaper = ShellSettings.settings.wallpaperUrl;
        }

        Image {
            id: fromImageSource
            source: panel.previousWallpaper
            fillMode: Image.PreserveAspectCrop
            anchors.fill: parent
            visible: false
        }

        Image {
            id: toImageSource
            source: panel.currentWallpaper
            fillMode: Image.PreserveAspectCrop
            anchors.fill: parent
            visible: false
        }

        ShaderEffectSource {
            id: fromImage
            sourceItem: fromImageSource
            hideSource: true
        }

        ShaderEffectSource {
            id: toImage
            sourceItem: toImageSource
            hideSource: true
        }

        property real randomOriginX: 0.5
        property real randomOriginY: 0.5

        ShaderEffect {
            id: circleEffect
            anchors.fill: parent

            property variant fromImage: fromImage
            property variant toImage: toImage
            property real progress: panel.transitionProgress
            property vector2d aspectRatio: Qt.vector2d(panel.width / panel.height, 1.0)
            property vector2d origin: Qt.vector2d(panel.randomOriginX, panel.randomOriginY)

            fragmentShader: "root:resources/shaders/wallpapertransition.frag.qsb"
        }

        NumberAnimation {
            id: transitionAnimation
            target: panel
            property: "transitionProgress"
            from: 0.0
            to: 1.0
            duration: 800
            easing.type: Easing.InOutCubic

            onFinished: {
                panel.previousWallpaper = panel.currentWallpaper;
            }
        }

        function startTransition() {
            panel.randomOriginX = Math.random();
            panel.randomOriginY = Math.random();
            if (toImageSource.status === Image.Ready) {
                transitionAnimation.start();
            }
        }

        Connections {
            target: ShellSettings.settings

            function onWallpaperUrlChanged() {
                let newWallpaper = ShellSettings.settings.wallpaperUrl;

                if (panel.previousWallpaper !== newWallpaper) {
                    panel.previousWallpaper = panel.currentWallpaper;
                    panel.currentWallpaper = newWallpaper;
                    panel.transitionProgress = 0.0;
                    panel.startTransition();
                }
            }
        }

        Connections {
            target: toImageSource

            function onStatusChanged() {
                if (toImageSource.status === Image.Ready && !transitionAnimation.running && panel.transitionProgress === 0.0) {
                    transitionAnimation.start();
                }
            }
        }
    }
}
