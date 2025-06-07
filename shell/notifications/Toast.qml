pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Wayland

import qs
import qs.widgets

StyledRectangle {
    id: root

    required property NotificationBacker backer
    required property var view

    property real displayX: view?.toastWidth ?? 0

    implicitWidth: view?.toastWidth ?? 0
    implicitHeight: Math.max(50, wrapper.implicitHeight)
    x: displayX

    visible: {
        if (ToplevelManager.activeToplevel?.fullscreen ?? false)
            return backer.showOnFullscreen;

        return true;
    }

    HoverHandler {
        id: hoverHandler
        blocking: true
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

        onHoveredChanged: if (root.backer) root.backer.hovered = hovered
    }

    WrapperItem {
        id: wrapper
        implicitWidth: parent.width
        margin: 8

        RowLayout {
            spacing: 8

            Loader {
                active: root.backer?.icon ?? false
                sourceComponent: root.backer?.icon ?? null

                onLoaded: visible = item.visible

                Layout.alignment: Qt.AlignTop
            }

            ColumnLayout {
                id: container
                spacing: 2

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop

                RowLayout {
                    spacing: 8

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // Summary (title) text
                    Text {
                        id: summaryText
                        text: root.backer?.summary ?? ""
                        color: ShellSettings.colors.active.text
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                        maximumLineCount: 1

                        Layout.fillWidth: true
                        Layout.preferredHeight: summaryText.contentHeight
                    }

                    // Buttons, typically close
                    Loader {
                        id: buttonsLoader
                        active: root.backer?.buttons ?? false
                        sourceComponent: root.backer?.buttons ?? null

                        Layout.alignment: Qt.AlignTop
                    }
                }

                // Body text
                Loader {
                    active: root.backer?.body ?? false
                    sourceComponent: root.backer?.body ?? null

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }

    Behavior on y {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    SequentialAnimation {
        id: enterAnim

        NumberAnimation {
            target: root
            property: "displayX"
            from: root.view?.toastWidth ?? 0
            to: -(root.view?.overshoot ?? 0)
            duration: 200
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: root
            property: "displayX"
            from: -(root.view?.overshoot ?? 0)
            to: 0
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    NumberAnimation {
        id: exitAnim
        target: root
        property: "displayX"
        from: 0
        to: root.view?.toastWidth ?? 0
        duration: 200
        easing.type: Easing.OutCubic

        property bool shouldDiscard: false

        onFinished: {
            if (root.backer) {
                if (shouldDiscard) {
                    // Defer discarded() to avoid issues with object destruction during signal handling
                    Qt.callLater(root.backer.discarded);
                } else {
                    root.backer.hidden = true;
                }
            }
        }
    }

    Connections {
        target: root.backer ?? null

        function onDiscard() {
            root.playExit(true);
        }

        function onHide() {
            root.playExit(false);
        }
    }

    function playEnter() {
        enterAnim.restart();
    }

    function playExit(discard: bool) {
        exitAnim.shouldDiscard = discard;
        exitAnim.restart();
    }
}
