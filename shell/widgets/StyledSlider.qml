pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import ".."

Slider {
    id: slider
    implicitHeight: 8
    property var accentColor: ShellSettings.colors.active

    background: Rectangle {
        id: sliderContainer
        width: slider.availableWidth
        height: slider.implicitHeight
        color: ShellSettings.colors.inactive
        radius: 4
        anchors.verticalCenter: parent.verticalCenter

        layer.enabled: true
        layer.effect: OpacityMask {
            source: Rectangle {
                width: sliderContainer.width
                height: sliderContainer.height
                radius: sliderContainer.radius
                color: "white"
            }

            maskSource: Rectangle {
                width: sliderContainer.width
                height: sliderContainer.height
                radius: sliderContainer.radius
                color: "black"
            }
        }

        Rectangle {
            id: fill
            width: slider.handle.width / 2 + slider.visualPosition * (sliderContainer.width - slider.handle.width)
            height: sliderContainer.height
            color: Qt.color(slider.accentColor ?? "purple").darker(1.2)
        }
    }

    handle: Rectangle {
        id: handleRect
        x: slider.visualPosition * (slider.availableWidth - width)
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: 16
        height: 16
        radius: width / 2
        color: slider.pressed ? Qt.color(slider.accentColor ?? "purple").darker(1.5) : slider.accentColor ?? "purple"
    }
}
