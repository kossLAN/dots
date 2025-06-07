pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import qs

Slider {
    id: slider
    implicitHeight: 7

    property var accentColor: ShellSettings.colors.active.accent
    property var railColor: ShellSettings.colors.active.light
    property real handleHeight: 16

    background: Item {
        id: sliderContainer
        width: slider.availableWidth
        height: slider.implicitHeight
        anchors.verticalCenter: parent.verticalCenter

        layer.enabled: true
        layer.effect: OpacityMask {
            source: Rectangle {
                width: sliderContainer.width
                height: sliderContainer.height
                radius: 5
                color: "white"
            }

            maskSource: Rectangle {
                width: sliderContainer.width
                height: sliderContainer.height
                radius: 5
                color: "black"
            }
        }

        Rectangle {
            id: rail
            color: slider.railColor
            height: sliderContainer.height
            width: sliderContainer.width
        }

        Rectangle {
            id: fill
            width: slider.handle.width / 2 + slider.visualPosition * (sliderContainer.width - slider.handle.width)
            height: sliderContainer.height
            color: Qt.color(slider.accentColor ?? "purple")
        }
    }

    handle: Rectangle {
        id: handleRect
        x: slider.visualPosition * (slider.availableWidth - width)
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: slider.handleHeight
        height: slider.handleHeight
        radius: width / 2

        color: {
            if (slider.pressed)
                return Qt.color(slider.accentColor ?? "purple").darker(1.5);
            else
                return slider.accentColor ?? "purple";
        }
    }
}
