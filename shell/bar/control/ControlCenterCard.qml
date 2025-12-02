import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs

WrapperMouseArea {
    id: root

    required property var title
    required property var description

    RowLayout {
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Text {
                text: root.title
                color: ShellSettings.colors.foreground
                font.pointSize: 10
            }

            Text {
                text: root.description
                color: ShellSettings.colors.foreground.darker(2.0)
                font.pointSize: 9
            }
        }

        IconImage {
            source: "root:resources/general/right-arrow.svg"
            Layout.preferredWidth: height
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignRight
            Layout.margins: 2
        }

        // Rectangle {
        //     Layout.preferredWidth: height
        //     Layout.fillHeight: true
        //     Layout.alignment: Qt.AlignRight
        //     Layout.margins: 2
        // }
    }
}
