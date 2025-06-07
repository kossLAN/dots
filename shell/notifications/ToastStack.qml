pragma ComponentBehavior: Bound

import QtQuick

// Shamelessly ripped from fox
Item {
    id: root
    onChildrenChanged: recalc()

    property real spacing: 0

    Instantiator {
        model: root.children

        Connections {
            required property Item modelData
            target: modelData

            function onImplicitHeightChanged() {
                root.recalc();
            }

            function onImplicitWidthChanged() {
                root.recalc();
            }

            function onVisibleChanged() {
                root.recalc();
            }
        }
    }

    function recalc() {
        let y = 0;
        let w = 0;

        for (const child of this.children) {
            if (!child.visible)
                continue;

            child.y = y;
            y += child.implicitHeight + root.spacing;

            if (child.implicitWidth > w)
                w = child.implicitWidth;
        }

        this.implicitHeight = y;
        this.implicitWidth = w;
    }
}
