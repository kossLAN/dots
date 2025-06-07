pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import ".."

Slider {
    id: root

    value: 0.5
    from: 0.0
    to: 1.0

    property string text
    property Component icon

    background: Rectangle {
        id: background
        implicitWidth: parent.width
        implicitHeight: parent.height
        width: root.availableWidth
        height: implicitHeight
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        z: 0
        color: ShellSettings.colors.active.base
        radius: height / 2

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: background.implicitWidth
                height: background.implicitHeight
                radius: background.radius
                color: "black"
            }
        }

        Rectangle {
            id: visualPos
            width: root.visualPosition * (root.availableWidth - root.height) + (root.height / 2)
            height: parent.height
            color: ShellSettings.colors.active.highlight
        }

        Text {
            id: sliderText
            text: root.text
            visible: text !== ""
            color: ShellSettings.colors.active.highlightedText
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight

            font {
                pointSize: Math.max(handle.implicitHeight * 0.35, 11)
            }

            anchors {
                top: parent.top
                bottom: parent.bottom
                left: {
                    let visualWidth = (root.visualPosition * root.availableWidth);
                    if ((visualWidth / root.availableWidth) < 0.5)
                        return visualPos.right;
                    else
                        return parent.left;
                }
                right: {
                    let visualWidth = (root.visualPosition * root.availableWidth);
                    if ((visualWidth / root.availableWidth) > 0.5)
                        return visualPos.right;
                    else
                        return parent.right;
                }

                leftMargin: 20
                rightMargin: 20
            }
        }
    }

    handle: Rectangle {
        id: handle
        color: ShellSettings.colors.active.highlight
        implicitWidth: root.height
        implicitHeight: root.height
        radius: width / 2

        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        // icon maybe

        Loader {
            active: root.icon !== undefined
            sourceComponent: root.icon

            anchors {
                fill: parent
                margins: 2
            }
        }
    }
}
