pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects

Rectangle {
    id: profileImage
    color: "transparent"

    Image {
        anchors.fill: parent
        source: "root:resources/general/pfp.png"
        sourceSize.width: 100
        sourceSize.height: 100

        layer.enabled: true
        layer.effect: OpacityMask {
            source: Rectangle {
                width: profileImage.width
                height: profileImage.height
                radius: 10
                color: "white"
            }

            maskSource: Rectangle {
                width: profileImage.width
                height: profileImage.height
                radius: 10
                color: "black"
            }
        }
    }
}
