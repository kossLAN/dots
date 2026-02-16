pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import qs
import qs.widgets

MouseArea {
    id: root

    required property int index
    required property string fileName
    required property string filePath
    required property bool fileIsDir
    required property double fileSize

    property bool selected: false
    property string sizeText: ""

    readonly property bool _isImage: {
        if (root.fileIsDir || !root.fileName)
            return false;

        const dot = root.fileName.lastIndexOf(".");

        if (dot < 0)
            return false;

        const ext = root.fileName.substring(dot + 1).toLowerCase();
        return ["png", "jpg", "jpeg", "gif", "svg", "bmp", "tiff", "ico"].includes(ext);
    }

    signal entryClicked
    signal entryDoubleClicked

    implicitHeight: 40
    height: implicitHeight
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton

    onClicked: root.entryClicked()
    onDoubleClicked: root.entryDoubleClicked()

    Rectangle {
        anchors.fill: parent
        radius: 0

        color: {
            if (root.selected)
                return ShellSettings.colors.active.highlight;

            if (root.containsMouse)
                return ShellSettings.colors.inactive.accent;

            if (root.index % 2 === 1)
                return Qt.rgba(ShellSettings.colors.active.light.r, ShellSettings.colors.active.light.g, ShellSettings.colors.active.light.b, 0.3);

            return "transparent";
        }

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 8

        ClippingRectangle {
            visible: root._isImage
            radius: 4
            color: "transparent"
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32

            Image {
                anchors.fill: parent
                source: root._isImage && root.filePath ? `file://${root.filePath}` : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                smooth: true
                sourceSize.width: 64
                sourceSize.height: 64
            }
        }

        Item {
            visible: !root._isImage
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32

            IconImage {
                anchors.centerIn: parent
                source: Quickshell.iconPath(root.fileIsDir ? "folder" : "text-x-generic")
                width: 20
                height: 20
            }
        }

        StyledText {
            text: root.fileName
            elide: Text.ElideRight
            font.pixelSize: 13
            Layout.fillWidth: true
        }

        StyledText {
            visible: root.sizeText !== ""
            text: root.sizeText
            opacity: 0.5
            font.pixelSize: 11
        }
    }
}
