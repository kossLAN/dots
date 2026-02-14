pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell

import qs
import qs.widgets

Item {
    id: root

    required property var picker

    RectangularShadow {
        radius: dialog.radius
        blur: 16
        spread: 2
        offset: Qt.vector2d(0, 4)
        color: Qt.rgba(0, 0, 0, 0.5)
        anchors.fill: dialog
    }

    StyledRectangle {
        id: dialog
        radius: 12
        anchors.fill: parent

        ColumnLayout {
            spacing: 8

            anchors {
                fill: parent
                margins: 12
            }

            FilePickerNavBar {
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                picker: root.picker
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 4

                FilePickerSidebar {
                    Layout.preferredWidth: 200
                    Layout.maximumWidth: 200
                    Layout.fillHeight: true
                    picker: root.picker
                }

                FilePickerFileArea {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    picker: root.picker
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                StyledText {
                    Layout.fillWidth: true
                    text: root.picker._selectedName
                    elide: Text.ElideMiddle
                    opacity: 0.7
                    font.pixelSize: 12
                }

                StyledButton {
                    implicitWidth: 80
                    implicitHeight: 32
                    color: ShellSettings.colors.active.mid
                    onClicked: root.picker._cancel()

                    StyledText {
                        anchors.centerIn: parent
                        text: "Cancel"
                    }
                }

                StyledButton {
                    color: ShellSettings.colors.active.mid
                    onClicked: root.picker._accept()
                    implicitWidth: 80
                    implicitHeight: 32

                    StyledText {
                        anchors.centerIn: parent
                        text: root.picker.folderMode ? "Select" : "Open"
                    }
                }
            }
        }
    }
}
