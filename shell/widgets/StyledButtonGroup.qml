pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import qs

Item {
    id: root

    property var model
    property Component delegate
    property color color: ShellSettings.colors.active.window
    property color borderColor: ShellSettings.colors.active.light

    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: containerRect.width
            height: containerRect.height
            radius: containerRect.radius
            color: "white"
        }
    }

    StyledRectangle {
        id: containerRect
        border.color: root.borderColor
        radius: 6
        anchors.fill: parent
        color: root.color
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: root.model

            delegate: Item {
                id: buttonDelegate

                required property var modelData
                required property int index

                Layout.fillWidth: true
                Layout.fillHeight: true

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Separator {
                        visible: buttonDelegate.index > 0
                        color: root.borderColor
                        Layout.preferredWidth: 1
                        Layout.fillHeight: true
                    }

                    Loader {
                        id: delegateLoader
                        sourceComponent: root.delegate
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        onLoaded: {
                            if (item) {
                                item.modelData = Qt.binding(() => buttonDelegate.modelData);
                                item.index = Qt.binding(() => buttonDelegate.index);
                            }
                        }
                    }
                }
            }
        }
    }
}
