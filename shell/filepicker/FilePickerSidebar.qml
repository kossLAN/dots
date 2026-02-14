pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import qs
import qs.widgets

ColumnLayout {
    id: root

    required property var picker

    property var shortcuts: [
        {
            name: "Home",
            icon: "user-home",
            path: `file://${root.picker.homePath}`
        },
        {
            name: "Documents",
            icon: "folder-documents",
            path: `file://${root.picker.homePath}/Documents`
        },
        {
            name: "Downloads",
            icon: "folder-download",
            path: `file://${root.picker.homePath}/Downloads`
        },
        {
            name: "Pictures",
            icon: "folder-pictures",
            path: `file://${root.picker.homePath}/Pictures`
        },
        {
            name: "Videos",
            icon: "folder-videos",
            path: `file://${root.picker.homePath}/Videos`
        },
        {
            name: "Desktop",
            icon: "user-desktop",
            path: `file://${root.picker.homePath}/Desktop`
        },
    ]

    spacing: 1

    Repeater {
        model: root.shortcuts

        Rectangle {
            id: shortcutItem

            required property var modelData
            required property int index

            Layout.fillWidth: true
            Layout.preferredHeight: 28
            radius: 6

            color: {
                if (root.picker.currentFolder.toString() === shortcutItem.modelData.path)
                    return ShellSettings.colors.inactive.highlight;

                if (shortcutMouse.containsMouse)
                    return ShellSettings.colors.active.highlight;

                return "transparent";
            }

            MouseArea {
                id: shortcutMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.picker._navigateTo(shortcutItem.modelData.path)
            }

            RowLayout {
                spacing: 4

                anchors {
                    fill: parent
                    leftMargin: 6
                    rightMargin: 4
                }

                IconImage {
                    source: Quickshell.iconPath(shortcutItem.modelData.icon)
                    Layout.preferredWidth: 18
                    Layout.preferredHeight: 18
                }

                StyledText {
                    text: shortcutItem.modelData.name
                    font.pixelSize: 13
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }
    }

    Item {
        Layout.fillHeight: true
    }
}
