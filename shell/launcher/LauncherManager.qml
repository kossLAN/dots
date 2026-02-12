pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets

Item {
    id: root

    required property list<LauncherBacker> model

    property list<LauncherBacker> enabledModel: model.filter(x => x.enabled)

    property alias currentIndex: root.switcher.currentIndex
    readonly property LauncherBacker currentItem: enabledModel[root.switcher.currentIndex]

    property Switcher switcher: Switcher {
        model: root.enabledModel.map(x => x.icon)
        parent: root.enabledModel[currentIndex].switcherParent
    }

    implicitWidth: wrapper.implicitWidth
    implicitHeight: wrapper.implicitHeight

    WrapperItem {
        id: wrapper
        child: root.currentItem.content

        property bool firstChild: true

        Component.onCompleted: firstChild = false

        onChildChanged: {
            if (!firstChild)
                opacityAnim.restart();
        }

        NumberAnimation {
            id: opacityAnim
            target: wrapper
            property: "opacity"
            from: 0
            to: 1
            duration: 200
            easing.type: Easing.InCubic
        }
    }
}
