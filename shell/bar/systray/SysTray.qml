pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "../../widgets"
import ".."

// TODO:
// 1. Get rid of leftItem/rightItem properties on menu
// 2. Load menu properly, right now its pretty buggy
// 3. Fix bug that causes close on update (nm-applet wifi networks updating)

RowLayout {
    id: root
    spacing: 5
    visible: SystemTray.items.values.length > 0

    required property var bar

    Repeater {
        id: repeater
        model: SystemTray.items

        delegate: StyledMouseArea {
            id: button
            Layout.preferredWidth: parent.height
            Layout.fillHeight: true

            required property SystemTrayItem modelData
            property bool showMenu: false

            onClicked: {
                menuOpener.menu = modelData.menu;
                showMenu = !showMenu;
            }

            IconImage {
                id: trayIcon
                anchors.fill: parent
                source: {
                    // console.log(trayField.modelData.id);
                    switch (button.modelData.id) {
                    case "obs":
                        return "image://icon/obs-tray";
                    default:
                        return button.modelData.icon;
                    }
                }
            }

            QsMenuOpener {
                id: menuOpener
            }

            property PopupItem menu: PopupItem {
                id: menu
                owner: button
                popup: root.bar.popup
                show: button.showMenu
                onClosed: button.showMenu = false

                implicitWidth: content.implicitWidth + (2 * 8)
                implicitHeight: content.implicitHeight + (2 * 8)

                property var leftItem: false
                property var rightItem: false

                ColumnLayout {
                    id: content
                    spacing: 2
                    anchors.centerIn: parent

                    Repeater {
                        model: menuOpener.children

                        delegate: TrayMenuItem {
                            id: sysTrayContent
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            rootMenu: menu

                            onInteracted: {
                                button.showMenu = false;
                                menuOpener.menu = null;
                            }
                        }
                    }
                }
            }
        }
    }
}
