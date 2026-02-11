pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.widgets

Item {
    id: root

    RowLayout {
        spacing: 8
        anchors.fill: parent

        ChatSidebar {
            Layout.fillHeight: true
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
