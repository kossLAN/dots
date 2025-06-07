import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import ".."

Slider {
    id: slider

    background: Rectangle {
        id: sliderContainer
        width: slider.availableWidth
        height: slider.implicitHeight
        color: "white"
        radius: 4

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
            id: handle
            width: sliderContainer.width * (slider.value / slider.to)
            height: sliderContainer.height
            color: ShellGlobals.colors.accent
        }
    }

    handle: Rectangle {
        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: 16
        height: 16
        radius: width / 2
        color: slider.pressed ? ShellGlobals.colors.accent.darker(1.2) : ShellGlobals.colors.accent

        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 1
            radius: 4.0
            samples: 9
            color: "#30000000"
        }
    }

    //handle: Item {}
}
