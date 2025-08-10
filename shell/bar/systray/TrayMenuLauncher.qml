pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import ".."

PopupItem {
    id: root
    onClicked: {
        menuOpener.menu = trayItem.menu;
        popup.set(menu);
    }

    required property PopupHandler popup
    required property SystemTrayItem trayItem

    menu: ColumnLayout {
        id: trayMenu
        spacing: 2
        // visible: false

        property var leftItem: false
        property var rightItem: false

        Repeater {
            model: menuOpener.children

            delegate: TrayMenuItem {
                id: sysTrayContent
                Layout.fillWidth: true
                Layout.fillHeight: true

                rootMenu: trayMenu

                onInteracted: {
                    menuOpener.menu = null;
                }
            }
        }
    }

    QsMenuOpener {
        id: menuOpener
    }

    IconImage {
        id: trayIcon
        anchors.fill: parent
        source: {
            // console.log(trayField.modelData.id);
            switch (root.trayItem.id) {
            case "obs":
                return "image://icon/obs-tray";
            default:
                return root.trayItem.icon;
            }
        }
    }
}
