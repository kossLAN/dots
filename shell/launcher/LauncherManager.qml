pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets

Item {
    id: root

    required property list<LauncherBacker> model

    property alias currentIndex: root.switcher.currentIndex

    property Switcher switcher: Switcher {
        model: root.model.map(x => x.icon)
        parent: root.model[currentIndex].switcherParent
    }

    implicitWidth: wrapper.implicitWidth
    implicitHeight: wrapper.implicitHeight

    WrapperItem {
        id: wrapper
        child: root.model[root.currentIndex].content

        onChildChanged: opacityAnim.restart()

        NumberAnimation {
            id: opacityAnim
            target: wrapper 
            property: "opacity"
            from: 0
            to: 1
            duration: 400
            easing.type: Easing.OutCubic
        }
    }
}
