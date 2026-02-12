pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import Quickshell.Services.SystemTray

import qs.widgets
import qs.bar.tray

TrayBacker {
    id: root

    required property SystemTrayItem item

    trayId: "systray-" + (item?.id ?? "unknown")
    enabled: item !== null

    icon: StyledMouseArea {
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: event => {
            event.accepted = true;

            if (event.button == Qt.LeftButton && root.item?.hasMenu) {
                root.clicked();
            } else if (event.button == Qt.RightButton) {
                root.item?.activate();
            } else if (event.button == Qt.MiddleButton) {
                root.item?.secondaryActivate();
            }
        }

        IconImage {
            property bool iconFromTheme: {
                if (root.item?.icon.startsWith("image://icon/"))
                    return true;

                return false;
            }

            source: root.item?.icon ?? ""

            anchors {
                fill: parent
                margins: iconFromTheme ? 0 : 4
            }
        }
    }

    menu: Item {
        id: menuContainer
        implicitWidth: menuContentLoader.width + (2 * 4)
        implicitHeight: menuContentLoader.height + (2 * 4)

        Loader {
            id: menuContentLoader
            anchors.centerIn: parent
            active: true

            sourceComponent: MenuView {
                menu: root.item?.menu ?? null
            }
        }
    }
}
