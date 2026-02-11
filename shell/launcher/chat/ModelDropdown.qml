pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs
import qs.widgets
import qs.services.chat

Item {
    id: root

    property color color: ShellSettings.colors.active.button

    property var groupedModels: {
        let groups = [];
        for (let provider of ChatConnector.providers) {
            if (!provider.enabled) continue;

            let items = [];

            for (let model of provider.models) {
                items.push({
                    label: model,
                    value: model,
                    providerId: provider.providerId
                });
            }

            groups.push({
                providerId: provider.providerId,
                providerName: provider.name,
                available: provider.available,
                models: items
            });
        }

        return groups;
    }

    property bool hasModels: {
        for (let group of groupedModels) {
            if (group.models.length > 0) return true;
        }
        return false;
    }

    property string displayText: {
        if (!hasModels) return "N/A";
        if (ChatConnector.currentModel === "") return "N/A";
        return ChatConnector.currentModel;
    }

    signal selected(string providerId, string model)

    property var rootItem: {
        let item = root;
        while (item.parent) {
            item = item.parent;
        }
        return item;
    }

    implicitWidth: 140
    implicitHeight: 32

    StyledRectangle {
        id: button

        color: {
            if (mouseArea.containsMouse)
                return root.color.lighter(1.5);
            return root.color;
        }

        radius: 6
        anchors.fill: parent

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 6

            StyledText {
                text: root.displayText
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            ExpandArrow {
                expanded: dropdownOverlay.visible
                animate: false
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                if (dropdownOverlay.visible) {
                    dropdownOverlay.visible = false;
                } else if (root.hasModels) {
                    let pos = root.mapToItem(root.rootItem, 0, root.height + 4);
                    dropdownOverlay.dropdownX = pos.x;
                    dropdownOverlay.dropdownY = pos.y;
                    dropdownOverlay.visible = true;
                }
            }
        }
    }

    Item {
        id: dropdownOverlay
        parent: root.rootItem
        anchors.fill: parent
        visible: false
        z: 999999

        property real dropdownX: 0
        property real dropdownY: 0

        MouseArea {
            anchors.fill: parent
            onClicked: dropdownOverlay.visible = false
            onWheel: event => event.accepted = true
        }

        StyledRectangle {
            id: dropdown
            radius: 6
            color: root.color
            x: dropdownOverlay.dropdownX
            y: dropdownOverlay.dropdownY
            width: root.width
            height: Math.min(dropdownContent.implicitHeight + 8, 300)

            Flickable {
                id: dropdownFlickable
                anchors.fill: parent
                anchors.margins: 4
                clip: true
                contentHeight: dropdownContent.implicitHeight
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: dropdownContent
                    width: dropdownFlickable.width
                    spacing: 4

                    Repeater {
                        model: root.groupedModels

                        ColumnLayout {
                            id: providerGroup

                            required property var modelData
                            required property int index

                            spacing: 2
                            Layout.fillWidth: true

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 24
                                color: "transparent"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: 6

                                    StyledText {
                                        text: providerGroup.modelData.providerName
                                        font.weight: Font.Medium
                                        font.pixelSize: 11
                                        opacity: 0.7
                                        Layout.fillWidth: true
                                    }

                                    Rectangle {
                                        width: 6
                                        height: 6
                                        radius: 3
                                        color: providerGroup.modelData.available ? "#4ade80" : "#ef4444"
                                    }
                                }
                            }

                            Repeater {
                                model: providerGroup.modelData.models

                                Rectangle {
                                    id: modelDelegate

                                    required property var modelData
                                    required property int index

                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 28
                                    radius: 4

                                    color: {
                                        if (modelMouse.containsMouse)
                                            return ShellSettings.colors.inactive.highlight;

                                        if (modelData.value === ChatConnector.currentModel &&
                                            modelData.providerId === ChatConnector.currentProviderId)
                                            return ShellSettings.colors.active.highlight;

                                        return "transparent";
                                    }

                                    StyledText {
                                        text: modelDelegate.modelData.label
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8
                                        elide: Text.ElideRight
                                        color: ShellSettings.colors.active.text
                                    }

                                    MouseArea {
                                        id: modelMouse
                                        anchors.fill: parent
                                        hoverEnabled: true

                                        onClicked: {
                                            root.selected(modelDelegate.modelData.providerId, modelDelegate.modelData.value);
                                            dropdownOverlay.visible = false;
                                        }
                                    }
                                }
                            }

                            Separator {
                                visible: providerGroup.index < root.groupedModels.length - 1
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                Layout.topMargin: 4
                                Layout.bottomMargin: 4
                            }
                        }
                    }
                }
            }
        }
    }
}
