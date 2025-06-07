pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import "../../../widgets/" as Widgets
import "../../.."

// TODO: refactor this trash
Rectangle {
    id: root
    required property var isSink
    color: "transparent"
    radius: 10

    property bool expanded: false
    property int baseHeight: 60
    property int contentHeight: expanded ? (applicationVolumes.count * baseHeight) : 0

    implicitHeight: baseHeight + contentHeight

    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: root.width
            height: root.height
            radius: root.baseHeight / 2
            color: "black"
        }
    }

    Item {
        id: headerSection
        width: parent.width
        height: root.baseHeight
        anchors.top: parent.top

        RowLayout {
            spacing: 0
            anchors.fill: parent

            Rectangle {
                color: ShellSettings.settings.colors["surface_container_high"]

                Widgets.IconButton {
                    id: arrowButton
                    implicitSize: 44
                    activeRectangle: false
                    source: "root:resources/general/right-arrow.svg"
                    padding: 4
                    rotation: root.expanded ? 90 : 0
                    anchors.centerIn: parent

                    Behavior on rotation {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutCubic
                        }
                    }

                    onClicked: {
                        root.expanded = !root.expanded;
                    }
                }

                Layout.preferredWidth: 40
                Layout.preferredHeight: root.baseHeight
            }

            Card {
                node: root.isSink ? Pipewire.defaultAudioSink : Pipewire.defaultAudioSource
                isSink: root.isSink
                Layout.fillWidth: true
                Layout.preferredHeight: root.baseHeight
            }
        }
    }

    Rectangle {
        id: divider
        color: ShellSettings.settings.colors["surface_bright"]
        height: 2
        width: parent.width
        anchors.top: headerSection.bottom

        opacity: root.expanded ? 1.0 : 0.0

        // Behavior on opacity {
        //     NumberAnimation {
        //         duration: 150
        //         easing.type: Easing.OutCubic
        //     }
        // }
    }

    Item {
        id: contentSection
        width: parent.width
        anchors.top: divider.bottom
        height: root.contentHeight
        clip: true

        // Behavior on height {
        //     SmoothedAnimation {
        //         duration: 150
        //         velocity: 200
        //         easing.type: Easing.OutCubic
        //     }
        // }

        Column {
            id: applicationsColumn
            width: parent.width
            anchors.top: parent.top
            opacity: root.expanded ? 1.0 : 0.0

            // Behavior on opacity {
            //     NumberAnimation {
            //         duration: 100
            //         easing.type: Easing.OutCubic
            //     }
            // }

            PwNodeLinkTracker {
                id: linkTracker
                node: root.isSink ? Pipewire.defaultAudioSink : Pipewire.defaultAudioSource
            }

            Repeater {
                id: applicationVolumes
                model: linkTracker.linkGroups

                delegate: RowLayout {
                    id: cardRow
                    required property PwLinkGroup modelData
                    spacing: 0
                    width: applicationsColumn.width
                    height: root.baseHeight

                    Rectangle {
                        color: ShellSettings.settings.colors["surface_container_high"]

                        IconImage {
                            implicitSize: 32
                            source: {
                                if (cardRow.modelData.source?.properties["application.icon-name"] == null) {
                                    return "root:resources/general/placeholder.svg";
                                }

                                return `image://icon/${cardRow.modelData.source?.properties["application.icon-name"]}`;
                            }

                            anchors {
                                fill: parent
                                leftMargin: 8
                                rightMargin: 8
                            }
                        }

                        Layout.preferredWidth: 40
                        Layout.preferredHeight: root.baseHeight
                    }

                    Card {
                        node: cardRow.modelData.source
                        isSink: root.isSink
                        Layout.fillWidth: true
                        Layout.preferredHeight: root.baseHeight
                    }
                }
            }
        }
    }
}
