import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.Mpris
import "../.."

PopupWindow {
    id: root
    width: mediaPlayerContainer.width + 10
    height: mediaPlayerContainer.height + 10
    color: "transparent"
    visible: mediaPlayerContainer.opacity > 0

    anchor.rect.x: parentWindow.width / 2 - width / 2
    anchor.rect.y: parentWindow.height

    function show() {
        mediaPlayerContainer.opacity = 1;
    }

    function hide() {
        mediaPlayerContainer.opacity = 0;
    }

    HoverHandler {
        id: hoverHandler
        enabled: true
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onHoveredChanged: {
            if (hovered == false) {
                hide();
            }
        }
    }

    Rectangle {
        id: mediaPlayerContainer
        width: 500
        height: mediaPlayerColumn.height + 20
        color: ShellGlobals.colors.base
        radius: 5
        opacity: 0
        anchors.centerIn: parent
        layer.enabled: true
        layer.effect: OpacityMask {
            source: Rectangle {
                width: mediaPlayerContainer.width
                height: mediaPlayerContainer.height
                radius: mediaPlayerContainer.radius
                color: "white"
            }

            maskSource: Rectangle {
                width: mediaPlayerContainer.width
                height: mediaPlayerContainer.height
                radius: mediaPlayerContainer.radius
                color: "black"
            }

            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                spread: 0.02
                samples: 25
                color: "#80000000"
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        ColorQuantizer {
            id: colorQuantizer
            source: Qt.resolvedUrl(Media.trackedPlayer?.trackArtUrl ?? "")
            depth: 2
            rescaleSize: 64

            onColorsChanged: {
                Media.colors = colors;
            }
        }

        ShaderEffect {
            property color topLeftColor: colorQuantizer?.colors[0] ?? "white"
            property color topRightColor: colorQuantizer?.colors[1] ?? "black"
            property color bottomLeftColor: colorQuantizer?.colors[2] ?? "white"
            property color bottomRightColor: colorQuantizer?.colors[3] ?? "black"

            anchors.fill: parent
            fragmentShader: "root:/shaders/vertexgradient.frag.qsb"
            vertexShader: "root:/shaders/vertexgradient.vert.qsb"

            Behavior on topLeftColor {
                ColorAnimation {
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
            Behavior on topRightColor {
                ColorAnimation {
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
            Behavior on bottomLeftColor {
                ColorAnimation {
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
            Behavior on bottomRightColor {
                ColorAnimation {
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
        }

        ColumnLayout {
            id: mediaPlayerColumn
            spacing: 10
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width
            Layout.margins: 10
            implicitHeight: childrenRect.height

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 10
            }

            // Media Cards
            Repeater {
                model: Mpris.players

                Card {
                    required property var modelData
                    player: modelData
                    Layout.fillWidth: true
                }
            }
        }
    }
}
