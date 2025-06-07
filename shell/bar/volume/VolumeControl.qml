pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import "../../widgets/" as Widgets

WrapperItem {
    id: root
    visible: false

    ColumnLayout {
        spacing: 10

        Widgets.TabBar {
            id: tabBar
            model: ["headphones", "tune"]
            Layout.fillWidth: true
            Layout.preferredHeight: 35
        }

        StackLayout {
            id: page
            currentIndex: tabBar.currentIndex
            Layout.fillWidth: true
            Layout.preferredHeight: currentItem ? currentItem.implicitHeight : 0

            readonly property Item currentItem: children[currentIndex]

            DeviceMixer {}
            ApplicationMixer {}
        }
    }
}
