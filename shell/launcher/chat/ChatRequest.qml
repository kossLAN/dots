pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets

import qs

Item {
    id: root

    required property string text
    property var images: []
    property color textColor: ShellSettings.colors.active.text
    property color selectedTextColor: ShellSettings.colors.active.highlightedText
    property color selectionColor: ShellSettings.colors.active.highlight
    property int fontSize: 13

    implicitHeight: contentColumn.implicitHeight

    ColumnLayout {
        id: contentColumn
        width: root.width
        spacing: 8

        Flow {
            visible: root.images && root.images.length > 0
            spacing: 6
            layoutDirection: Qt.RightToLeft

            Layout.fillWidth: true

            Repeater {
                model: root.images ?? []

                ClippingRectangle {
                    id: imageContainer

                    required property var modelData
                    required property int index

                    width: 64
                    height: 64
                    radius: 6
                    color: "transparent"

                    Image {
                        source: "data:" + imageContainer.modelData.mediaType + ";base64," + imageContainer.modelData.base64
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        anchors.fill: parent
                    }
                }
            }
        }

        // User message text
        TextEdit {
            id: userMessage
            text: root.text
            color: root.textColor
            wrapMode: Text.Wrap
            font.pixelSize: root.fontSize
            textFormat: TextEdit.PlainText
            readOnly: true
            selectByMouse: true
            selectedTextColor: root.selectedTextColor
            selectionColor: root.selectionColor
            horizontalAlignment: Text.AlignRight

            Layout.fillWidth: true
        }
    }
}
