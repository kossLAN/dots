import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.Pipewire
import "../.."

PopupWindow {
    id: root
    width: mainContainer.width + 10
    height: mainContainer.height + 10
    color: "transparent"
    visible: mainContainer.opacity > 0

    function show() {
        mainContainer.opacity = 1;
    }

    function hide() {
        mainContainer.opacity = 0;
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
        id: mainContainer
        width: 400
        height: 400
        color: ShellGlobals.colors.base
        radius: 5
        opacity: 0
        anchors.centerIn: parent

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            spread: 0.02
            samples: 25
            color: "#80000000"
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            id: mainColumn
            spacing: 10
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width
            Layout.margins: 10

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 10
            }

            PwNodeLinkTracker {
                id: linkTracker
                node: Pipewire.defaultAudioSink
            }

            Card {
                node: Pipewire.defaultAudioSink
                Layout.fillWidth: true
                Layout.preferredHeight: 50
            }

            Rectangle {
                Layout.fillWidth: true
                color: ShellGlobals.colors.light
                implicitHeight: 2
                radius: 1
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                contentWidth: availableWidth

                ColumnLayout {
                    width: parent.width
                    spacing: 10

                    Repeater {
                        model: linkTracker.linkGroups

                        Card {
                            required property PwLinkGroup modelData

                            node: modelData.source
                            Layout.fillWidth: true
                            Layout.preferredHeight: 45
                        }
                    }
                }
            }
        }
    }
}
