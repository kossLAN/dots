pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import ".."

Scope {
    id: root

    required property var screen
    property alias topWindow: topPanel
    property alias top: topPanel.data

    PanelWindow {
        id: overlay
        color: "transparent"
        screen: root.modelData
        mask: Region {}

        anchors {
            left: true
            right: true
            top: true
            bottom: true
        }

        Item {
            anchors.fill: parent

            Rectangle {
                anchors.fill: parent
                color: ShellSettings.colors["surface"]
                // visible: false

                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: mask
                    maskInverted: true  // Changed from true to false
                    maskThresholdMin: 0.5
                    maskSpreadAtMin: 1
                }
            }

            Item {
                id: mask
                anchors.fill: parent
                layer.enabled: true
                visible: false

                Rectangle {
                    color: "white"
                    radius: 15

                    anchors {
                        fill: parent
                        margins: ShellSettings.sizing.borderWidth
                        topMargin: ShellSettings.sizing.topBorderWidth
                    }
                }
            }
        }
    }

    PanelWindow {
        id: topPanel
        screen: root.modelData
        color: "transparent"
        implicitHeight: ShellSettings.sizing.topBorderWidth

        anchors {
            top: true
            left: true
            right: true
        }
    }

    PanelWindow {
        id: bottomPanel
        screen: root.modelData
        color: "transparent"
        implicitHeight: ShellSettings.sizing.borderWidth

        anchors {
            bottom: true
            left: true
            right: true
        }
    }

    PanelWindow {
        id: leftPanel
        screen: root.modelData
        color: "transparent"
        implicitWidth: ShellSettings.sizing.borderWidth

        anchors {
            top: true
            bottom: true
            left: true
        }
    }

    PanelWindow {
        id: rightPanel
        screen: root.modelData
        color: "transparent"
        implicitWidth: ShellSettings.sizing.borderWidth

        anchors {
            top: true
            bottom: true
            right: true
        }
    }
}
