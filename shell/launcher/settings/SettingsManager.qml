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

        ColumnLayout {
            spacing: 4
            Layout.preferredWidth: 24
            Layout.fillHeight: true

            ListView {
                id: switcher
                spacing: 4
                interactive: false
                highlightFollowsCurrentItem: true
                highlightMoveVelocity: -1
                highlightMoveDuration: 200
                highlightRangeMode: ListView.ApplyRange
                snapMode: ListView.SnapToItem

                Layout.preferredWidth: 24
                Layout.fillHeight: true

                model: root.enabledModel.map(x => x.icon)

                delegate: StyledMouseArea {
                    id: delegateButton

                    required property var modelData
                    required property var index

                    radius: 4
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
                    radius: 4
                }
            }
        }

        Separator {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            StyledText {
                text: root.enabledModel[root.currentIndex].summary
                font.pointSize: 9
                font.weight: Font.Medium
                Layout.topMargin: 8
            }

            Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
            }

            Loader {
                id: wrapper
                active: root.enabledModel[root.currentIndex].content
                sourceComponent: root.enabledModel[root.currentIndex].content

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 4

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
}
