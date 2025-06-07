import QtQuick

Item {
    id: root
    visible: false
    opacity: root.targetOpacity
    width: implicitWidth
    height: fullHeight && popup?.parentItem ? popup.parentItem.height : implicitHeight

    property real scaleMul: popup?.scaleMul ?? 1
    property real originX: popup?.cachedOriginX ?? 0

    transform: Scale {
        origin.x: {
            if (root.expand === Popup.ExpandRight)
                return root.width;
            else if (root.expand === Popup.ExpandLeft)
                return 0;
            else
                return root.originX;
        }

        origin.y: 0

        xScale: {
            if (root.expand !== Popup.ExpandTop)
                return 1;
            return root.scaleMul;
        }

        yScale: {
            if (root.fullHeight)
                return 1;
            return root.scaleMul;
        }
    }

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
        implicitHeight: children[0]?.implicitHeight ?? 100
        implicitWidth: children[0]?.implicitWidth ?? 100
        anchors.fill: parent
    }

    required property var popup
    required property var owner
    property bool centered: false
    property bool show: false
    property bool animate: true
    property int expand: Popup.ExpandTop
    property bool fullHeight: false
    property Component backgroundComponent: null 

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
