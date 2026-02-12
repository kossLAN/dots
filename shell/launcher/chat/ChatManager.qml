pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.widgets

Item {
    id: root

    RowLayout {
        // spacing: 8
        spacing: 0
        anchors.fill: parent

        ChatSidebar {
            Layout.fillHeight: true
            Layout.margins: 8
        }

        Separator {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
        }

        ChatWindow {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
