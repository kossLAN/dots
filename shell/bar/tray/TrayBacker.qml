import QtQuick
import Quickshell

import qs

Scope {
    required property string trayId
    property bool enabled: true

    readonly property bool pinned: {
        if (ShellSettings.settings.pinnedTray)
            return ShellSettings.settings.pinnedTray.includes(trayId);

        return false;
    }

    property string icon: "settings"
    property Component button: Item {}
    property Component menu: null

    signal clicked
}
