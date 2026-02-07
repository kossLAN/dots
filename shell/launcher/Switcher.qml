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
    property real itemSize: 24

    implicitWidth: model.length * itemSize + (model.length - 1) * spacing
    implicitHeight: itemSize
    width: implicitWidth
    height: implicitHeight

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

        width: root.width
        height: root.height

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
            width: root.itemSize
            height: root.itemSize

            onClicked: root.currentIndex = index

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
