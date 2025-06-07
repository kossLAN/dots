import QtQuick
import qs.widgets

Item {
    id: root
    visible: false
    opacity: root.targetOpacity

    onShowChanged: {
        if (show) {
            popup.setItem(this);
        } else {
            popup.removeItem(this);
        }
    }

    onTargetVisibleChanged: {
        if (targetVisible) {
            visible = true;
            targetOpacity = 1;
        } else {
            console.log("closed");
            closed();
            targetOpacity = 0;
        }
    }

    onTargetOpacityChanged: {
        if (!targetVisible && targetOpacity == 0) {
            visible = false;
            this.parent = null;
            if (popup)
                popup.onHidden(this);
        }
    }

    readonly property alias contentItem: contentItem
    default property alias data: contentItem.data
    readonly property Item item: contentItem

    Item {
        id: contentItem
        anchors.fill: parent
        // anchors.margins: 5

        implicitHeight: children[0].implicitHeight
        implicitWidth: children[0].implicitWidth
    }

    required property var popup
    required property var owner
    property bool centered: false
    property bool show: false

    signal closed

    property bool targetVisible: false
    property real targetOpacity: 0

    Behavior on targetOpacity {
        id: opacityAnimation
        SmoothedAnimation {
            velocity: 5
        }
    }
}
