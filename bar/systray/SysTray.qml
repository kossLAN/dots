pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "../.."

RowLayout {
    id: root
    spacing: 10
    visible: SystemTray.items.values.length > 0
    implicitHeight: parent.height

    required property var popup

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: trayField
            implicitHeight: parent.height
            implicitWidth: trayContainer.width
            required property SystemTrayItem modelData

            MouseArea {
                id: trayButton
                hoverEnabled: true
                anchors.fill: parent
                onClicked: {
                    menuOpener.menu = trayField.modelData.menu;

                    if (root.popup.content == trayMenu) {
                        root.popup.hide();
                        return;
                    }

                    root.popup.set(this, trayMenu);
                    root.popup.show();
                }
            }

            QsMenuOpener {
                id: menuOpener
            }

            WrapperItem {
                id: trayMenu
                visible: false

                ColumnLayout {
                    id: menuContainer
                    spacing: 2

                    Repeater {
                        model: menuOpener.children

                        delegate: TrayMenu {
                            id: sysTrayContent
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            onInteracted: {
                                root.popup.hide();
                                menuOpener.menu = null;
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: trayContainer
                color: trayButton.containsMouse ? ShellSettings.settings.colors["primary"] : "transparent"
                radius: width / 2
                implicitHeight: parent.height - 2
                implicitWidth: parent.height - 2
                anchors.centerIn: parent

                IconImage {
                    id: trayIcon

                    source: {
                        switch (trayField.modelData.id) {
                        case "obs":
                            return "image://icon/obs-tray";
                        default:
                            return trayField.modelData.icon;
                        }
                    }

                    anchors {
                        fill: parent
                        margins: 1
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 100
                    }
                }
            }
        }
    }
}
