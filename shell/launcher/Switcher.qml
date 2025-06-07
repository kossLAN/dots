pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import qs
import qs.widgets

Item {
    id: root

    property alias model: listView.model
    property int currentIndex: 0
    property real spacing: 4
    property real radius: 8

    signal clicked(int index)

    implicitWidth: model.length * (height + spacing)

    ListView {
        id: listView
        spacing: root.spacing
        orientation: ListView.Horizontal
        model: root.model
        interactive: false
        currentIndex: root.currentIndex

        highlightFollowsCurrentItem: true
        highlightResizeDuration: 0 // stop resize anim
        highlightRangeMode: ListView.ApplyRange
        snapMode: ListView.SnapToItem

        anchors.fill: parent

        highlight: Rectangle {
            color: ShellSettings.colors.active.light
            radius: root.radius
        }

        delegate: StyledMouseArea {
            id: button

            required property var modelData
            required property var index

            property bool checked: ListView.isCurrentItem

            radius: root.radius
            width: (ListView.view.width - root.spacing) / root.model.length - 1
            height: ListView.view.height

            onClicked: {
                root.clicked(button.index);
            }

            IconImage {
                source: Quickshell.iconPath(button.modelData)

                anchors.fill: parent

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
            }
        }
    }
}
