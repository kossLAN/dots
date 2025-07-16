pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "../../widgets" as Widgets

RowLayout {
    id: root
    spacing: 5
    visible: SystemTray.items.values.length > 0

    // required property var popup
    required property var bar

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: trayField
            Layout.preferredWidth: parent.height
            Layout.fillHeight: true
            required property SystemTrayItem modelData

            Widgets.StyledMouseArea {
                id: trayButton
                hoverEnabled: true
                onClicked: {
                    menuOpener.menu = trayField.modelData.menu;

                    if (trayMenu.visible) {
                        trayMenu.visible = false;
                        // root.popup.hide();

                        return;
                    }

                    trayMenu.visible = true;

                    // root.popup.set(this, trayMenu);
                    // root.popup.show();
                }

                anchors {
                    fill: parent
                    // margins: 2
                }

                IconImage {
                    id: trayIcon
                    source: {
                        // console.log(trayField.modelData.id);
                        switch (trayField.modelData.id) {
                        case "obs":
                            return "image://icon/obs-tray";
                        default:
                            return trayField.modelData.icon;
                        }
                    }

                    anchors {
                        fill: parent
                        margins: 2
                    }
                }
            }

            QsMenuOpener {
                id: menuOpener
            }

            Widgets.StyledPopup {
                id: trayMenu
                // visible: false

                property var leftItem: false
                property var rightItem: false

                anchor {
                    window: root.bar
                    item: trayButton
                    margins.top: root.bar.height + 5
                }

                ColumnLayout {
                    id: menuContainer
                    spacing: 2

                    Repeater {
                        model: menuOpener.children

                        delegate: TrayMenuItem {
                            id: sysTrayContent
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            rootMenu: trayMenu

                            onInteracted: {
                                root.popup.hide();
                                menuOpener.menu = null;
                            }
                        }
                    }
                }
            }
        }
    }
}
