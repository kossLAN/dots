pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import qs
import qs.widgets

Item {
    Layout.fillWidth: true
    Layout.fillHeight: true

    ColumnLayout {
        id: root
        spacing: 8

        anchors {
            fill: parent
            margins: 8
        }

        StyledListView {
            model: ["background", "foreground", "foregroundDim", "accent", "highlight", "trim", "border", "borderSubtle"]
            spacing: 8

            Layout.fillWidth: true
            Layout.fillHeight: true

            delegate: StyledRectangle {
                id: card
                clip: true

                implicitWidth: ListView.view.width
                implicitHeight: 80

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: card.width
                        height: card.height
                        radius: card.radius
                        color: "black"
                    }
                }

                required property var modelData
                property color modelColor: ShellSettings.colors[card.modelData]

                RowLayout {
                    spacing: 8
                    anchors.fill: parent

                    Rectangle {
                        color: card.modelColor

                        Layout.preferredWidth: height
                        Layout.fillHeight: true
                    }

                    StyledText {
                        text: card.modelData
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    StyledRectangle {
                        radius: 6
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: textInput.implicitHeight + 15
                        Layout.rightMargin: 8

                        TextInput {
                            id: textInput
                            color: ShellSettings.colors.highlight
                            text: card.modelColor.toString()
                            onAccepted: card.modelColor = Qt.color(text)

                            anchors {
                                left: parent.left
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                leftMargin: 7.5
                                rightMargin: 7.5
                            }
                        }
                    }
                }
            }
        }
    }
}
