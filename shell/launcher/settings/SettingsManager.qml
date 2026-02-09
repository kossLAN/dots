pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import qs
import qs.widgets

Item {
    id: root

    required property list<SettingsBacker> model

    property list<SettingsBacker> enabledModel: model.filter(x => x.enabled)

    property alias currentIndex: switcher.currentIndex

    RowLayout {
        spacing: 8
        anchors.fill: parent

        StyledRectangle {
            color: ShellSettings.colors.active.mid
            radius: 8

            Layout.preferredWidth: 40
            Layout.fillHeight: true

            ListView {
                id: switcher
                spacing: 2
                interactive: false
                highlightFollowsCurrentItem: true
                highlightMoveVelocity: -1
                highlightMoveDuration: 200
                highlightRangeMode: ListView.ApplyRange
                snapMode: ListView.SnapToItem

                model: root.enabledModel.map(x => x.icon)

                delegate: StyledMouseArea {
                    id: delegateButton

                    required property var modelData
                    required property var index

                    implicitWidth: ListView.view.width
                    implicitHeight: ListView.view.width

                    onClicked: root.currentIndex = index

                    IconImage {
                        source: Quickshell.iconPath(delegateButton.modelData)
                        anchors.fill: parent
                    }
                }

                highlight: Rectangle {
                    color: ShellSettings.colors.active.light
                    radius: 10 
                }

                anchors {
                    fill: parent
                    margins: 6
                }
            }
        }

        Loader {
            id: wrapper
            active: root.enabledModel[root.currentIndex].content
            sourceComponent: root.enabledModel[root.currentIndex].content

            Layout.fillWidth: true
            Layout.fillHeight: true

            onSourceComponentChanged: opacityAnim.restart()

            NumberAnimation {
                id: opacityAnim
                target: wrapper
                property: "opacity"
                from: 0
                to: 1
                duration: 400
                easing.type: Easing.OutCubic
            }
        }
    }
}
