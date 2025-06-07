pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import qs

// Oh my god, the code for this previously was REALLY bad, what the fuck
// was I doing when I wrote it.
StyledRectangle {
    id: root

    property alias model: listView.model
    property int currentIndex: 0
    property real spacing: 4

    color: ShellSettings.colors.active.mid
    radius: 8

    // margins (spacing * 2) + square items (model.length * implicitHeight) + gaps between items ((model.length - 1) * spacing)
    implicitWidth: (spacing * 2) + (model.length * (implicitHeight - spacing * 2)) + ((model.length - 1) * spacing)

    ListView {
        id: listView
        spacing: root.spacing
        orientation: ListView.Horizontal
        model: root.model
        interactive: false
        currentIndex: root.currentIndex

        highlightFollowsCurrentItem: true
        highlightRangeMode: ListView.ApplyRange
        highlightResizeDuration: 0 // stop resize anim
        highlightMoveDuration: 150
        snapMode: ListView.SnapToItem

        // Disable highlight animation briefly on completion to prevent initial slide
        Component.onCompleted: {
            highlightMoveDuration = 0;
            Qt.callLater(() => highlightMoveDuration = 150);
        }

        anchors {
            fill: parent
            margins: root.spacing
        }

        highlight: Rectangle {
            color: ShellSettings.colors.active.light
            radius: root.radius - (root.spacing / 2)
        }

        delegate: StyledMouseArea {
            id: button

            required property var modelData
            required property var index

            property bool checked: ListView.isCurrentItem

            radius: root.radius - (root.spacing / 2)
            width: (ListView.view.width - (root.spacing * (root.model.length - 1))) / root.model.length
            height: ListView.view.height

            onClicked: {
                listView.currentIndex = button.index;
                root.currentIndex = button.index;
            }

            IconImage {
                source: Quickshell.iconPath(button.modelData)

                anchors {
                    fill: parent
                    margins: 2
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                    }
                }
            }
        }
    }
}
