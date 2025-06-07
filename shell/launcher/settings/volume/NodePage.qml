pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import qs
import qs.widgets

Item {
    id: root

    required property var nodes
    required property PwNode defaultNode

    required property string title
    required property string icon
    required property string mutedIcon
    required property string emptyText

    signal setDefault(node: PwNode)

    PwObjectTracker {
        objects: [root.defaultNode]
    }

    PwObjectTracker {
        objects: root.nodes
    }

    ColumnLayout {
        spacing: 6
        anchors.fill: parent

        DefaultDeviceCard {
            title: root.title
            icon: root.icon
            mutedIcon: root.mutedIcon
            node: root.defaultNode
        }

        RowLayout {
            spacing: 6
            Layout.fillWidth: true

            StyledText {
                text: root.title.replace("Default ", "") + "s"
                font.pointSize: 9
            }

            Item {
                Layout.fillWidth: true
            }

            StyledText {
                text: `${root.nodes.length} available`
                color: ShellSettings.colors.active.windowText.darker(1.5)
                font.pointSize: 9
            }
        }

        Separator {
            Layout.fillWidth: true
        }

        StyledListView {
            id: nodeList
            model: root.nodes
            spacing: 4
            clip: true
            visible: root.nodes.length > 0

            Layout.fillWidth: true
            Layout.fillHeight: true

            delegate: StyledRectangle {
                id: nodeCard
                color: ShellSettings.colors.active.base
                clip: true

                required property PwNode modelData
                required property int index

                property bool isDefault: modelData === root.defaultNode

                implicitWidth: ListView.view.width
                implicitHeight: 48

                RowLayout {
                    spacing: 8
                    anchors {
                        fill: parent
                        margins: 8
                    }

                    IconImage {
                        source: Quickshell.iconPath(root.icon)
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                    }

                    ColumnLayout {
                        spacing: 2
                        Layout.fillWidth: true

                        StyledText {
                            text: nodeCard.modelData ? (nodeCard.modelData.nickname || nodeCard.modelData.description) : "Unknown"
                            font.pointSize: 9
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        StyledText {
                            text: nodeCard.modelData?.name ?? ""
                            color: ShellSettings.colors.active.windowText.darker(1.5)
                            font.pointSize: 9
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    StyledMouseArea {
                        enabled: nodeCard.modelData?.audio !== null

                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24

                        onClicked: {
                            if (nodeCard.modelData?.audio) {
                                nodeCard.modelData.audio.muted = !nodeCard.modelData.audio.muted;
                            }
                        }

                        IconImage {
                            anchors.fill: parent
                            source: {
                                if (nodeCard.modelData?.audio?.muted) {
                                    return Quickshell.iconPath(root.mutedIcon);
                                }
                                return Quickshell.iconPath(root.icon);
                            }
                        }
                    }

                    StyledMouseArea {
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16

                        onClicked: {
                            if (nodeCard.modelData) {
                                root.setDefault(nodeCard.modelData);
                            }
                        }

                        RadioButton {
                            anchors.fill: parent
                            checked: nodeCard.isDefault
                        }
                    }
                }
            }
        }

        // Empty state
        Item {
            visible: root.nodes.length === 0
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 12

                IconImage {
                    source: Quickshell.iconPath(root.icon)
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    Layout.alignment: Qt.AlignHCenter
                    opacity: 0.5
                }

                StyledText {
                    text: root.emptyText
                    horizontalAlignment: Text.AlignHCenter
                    color: ShellSettings.colors.active.windowText.darker(1.5)
                    font.pointSize: 9
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
