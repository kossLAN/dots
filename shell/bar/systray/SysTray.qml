pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.bar
import qs.widgets

RowLayout {
    id: root
    visible: SystemTray.items.values.length > 0
    implicitWidth: childrenRect.width
    spacing: 5

    required property var bar

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: item
            required property SystemTrayItem modelData

            property bool showMenu: false

            Layout.preferredWidth: height
            Layout.fillHeight: true

            StyledMouseArea {
                id: mouseArea
                width: height
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                IconImage {
                    // property bool iconFromTheme: {
                    //     const iconName = item.modelData.icon.split("current-iconimage://icon/")[1];
                    //
                    //     return Quickshell.hasThemeIcon(iconName);
                    // }

                    source: item.modelData.icon

                    anchors {
                        fill: parent
                        // margins: iconFromTheme ? 2 : 0
                    }
                }

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }

                onClicked: event => {
                    event.accepted = true;

                    if (event.button == Qt.LeftButton && item.modelData.hasMenu) {
                        item.showMenu = !item.showMenu;
                    } else if (event.button == Qt.RightButton) {
                        item.modelData.activate();
                    } else if (event.button == Qt.MiddleButton) {
                        item.modelData.secondaryActivate();
                    }
                }

                property var menu: PopupItem {
                    id: menu
                    owner: mouseArea
                    popup: root.bar.popup

                    show: item.showMenu
                    animate: !(menuContentLoader?.item?.animating ?? false)

                    implicitWidth: menuContentLoader.width + (2 * 4)
                    implicitHeight: menuContentLoader.height + (2 * 4)

                    onClosed: item.showMenu = false

                    Loader {
                        id: menuContentLoader
                        active: item.showMenu || menu.visible

                        anchors.centerIn: parent

                        sourceComponent: MenuView {
                            menu: item.modelData.menu
                            onClose: item.showMenu = false
                        }
                    }
                }
            }
        }
    }
}
