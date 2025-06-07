pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import qs
import qs.widgets
import qs.launcher

StyledMouseArea {
    id: root
    visible: ShellSettings.settings.searchEnabled
    onClicked: Launcher.launcherOpen = !Launcher.launcherOpen 

    IconImage {
        anchors.fill: parent
        source: Quickshell.iconPath("search")
    }
}
