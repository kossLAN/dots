import QtQuick
import Quickshell
import Quickshell.Widgets

Item {
    id: root

    property bool expanded: false
    // signal clicked

    readonly property bool open: progress != 0
    readonly property bool animating: internalProgress != (expanded ? 101 : -1)

    implicitHeight: 24
    implicitWidth: 24

    property real internalProgress: expanded ? 101 : -1

    Behavior on internalProgress {
        SmoothedAnimation {
            velocity: 300
        }
    }

    EasingCurve {
        id: curve
        curve.type: Easing.InOutQuad
    }

    readonly property real progress: curve.valueAt(Math.min(100, Math.max(internalProgress, 0)) * 0.01)

    rotation: progress * 90

    IconImage {
        anchors.fill: parent
        source: "root:resources/general/right-arrow.svg"
    }

    // MouseArea {
    //     anchors.fill: parent
    //     onClicked: root.clicked()
    // }
}
