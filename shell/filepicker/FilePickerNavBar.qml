pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell

import qs
import qs.widgets

RowLayout {
    id: root

    required property var picker

    spacing: 4

    IconButton {
        implicitSize: 24
        source: Quickshell.iconPath("go-previous")
        enabled: root.picker._history.length > 0
        opacity: enabled ? 1.0 : 0.3
        onClicked: root.picker._navigateBack()
    }

    IconButton {
        source: Quickshell.iconPath("go-up")
        enabled: root.picker.currentFolder.toString() !== "file:///"
        opacity: enabled ? 1.0 : 0.3
        implicitSize: 24
        onClicked: root.picker._navigateUp()
    }

    // Editable path bar
    StyledRectangle {
        radius: 6
        color: ShellSettings.colors.active.alternateBase
        Layout.fillWidth: true
        Layout.preferredHeight: 28

        TextInput {
            id: pathInput

            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            verticalAlignment: TextInput.AlignVCenter
            color: ShellSettings.colors.active.text
            clip: true
            text: root.picker._displayPath()
            selectByMouse: true

            onAccepted: {
                let path = text.trim();

                if (path === "")
                    return;

                if (!path.startsWith("/"))
                    path = "/" + path;

                root.picker._navigateTo(`file://${path}`);
            }

            Text {
                text: "/"
                color: ShellSettings.colors.active.text
                opacity: 0.5
                visible: !pathInput.text
                verticalAlignment: Text.AlignVCenter
                anchors.fill: parent
            }
        }
    }

    IconButton {
        source: Quickshell.iconPath(root.picker.showHidden ? "view-visible" : "view-hidden")
        implicitSize: 24
        onClicked: root.picker.showHidden = !root.picker.showHidden
    }
}
