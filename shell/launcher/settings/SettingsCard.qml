import QtQuick
import QtQuick.Layouts

import qs.widgets

Item {
    id: root

    property string title: ""
    property string summary: ""

    property Component controls: Item {}

    RowLayout {
        anchors.fill: parent

        ColumnLayout {
            spacing: 2

            Layout.fillWidth: true
            Layout.fillHeight: true

            StyledText {
                text: root.title 
                font.pointSize: 9
            }

            StyledText {
                text: root.summary
                font.pointSize: 9
                opacity: 0.7
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Loader {
            active: root.controls
            sourceComponent: root.controls

            Layout.fillHeight: true
        }
    }
}
