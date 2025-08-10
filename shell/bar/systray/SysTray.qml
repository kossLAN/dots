pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import ".."

RowLayout {
    id: root
    spacing: 5
    visible: SystemTray.items.values.length > 0

    required property PopupHandler popup

    Repeater {
        id: repeater
        model: SystemTray.items

        delegate: TrayMenuLauncher {
            id: trayItem
            required property SystemTrayItem modelData
            trayItem: modelData
            popup: root.popup
            Layout.preferredWidth: parent.height
            Layout.fillHeight: true
        }
    }
}
