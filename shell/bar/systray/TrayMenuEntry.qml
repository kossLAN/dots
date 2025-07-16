import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../widgets" as Widgets
import "../.."

ColumnLayout {
    id: root
    required property QsMenuEntry menuData
    required property var rootMenu
    signal interacted

    Component.onCompleted: {
        if (menuData?.buttonType !== QsMenuButtonType.None || menuData?.icon != "") {
            rootMenu.leftItem = true;
        }

        if (menuData?.hasChildren) {
            rootMenu.rightItem = true;
        }
    }

    WrapperRectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 25
        radius: 4
        color: {
            if (!root.menuData?.enabled)
                return "transparent";

            if (entryArea.containsMouse) {
                let base = ShellSettings.colors.active;
                return Qt.rgba(base.r, base.g, base.b, 0.15);
            }

            return "transparent";
        }

        WrapperMouseArea {
            id: entryArea
            hoverEnabled: true
            anchors.fill: parent
            onClicked: {
                if (!root.menuData?.enabled)
                    return;

                if (root.menuData?.hasChildren) {
                    subTrayMenu.visible = !subTrayMenu.visible;
                    return;
                }

                root.menuData?.triggered();
                root.interacted();
            }

            RowLayout {
                id: menuEntry
                spacing: 5
                Layout.fillWidth: true

                Item {
                    visible: root.rootMenu.leftItem
                    Layout.preferredWidth: 20
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 5

                    RadioButton {
                        id: radioButton
                        visible: (root.menuData?.buttonType === QsMenuButtonType.RadioButton) ?? false
                        checked: (root.menuData?.checkState) ?? false
                        anchors.centerIn: parent
                    }

                    CheckBox {
                        id: checkBox
                        visible: (root.menuData?.buttonType === QsMenuButtonType.CheckBox) ?? false
                        checked: (root.menuData?.checkState) ?? false
                        anchors.centerIn: parent
                    }

                    IconImage {
                        id: entryImage
                        visible: (root.menuData?.buttonType === QsMenuButtonType.None && root.menuData?.icon !== "") ?? false
                        source: (root.menuData?.icon) ?? ""
                        anchors.fill: parent
                    }
                }

                Text {
                    id: text
                    text: root.menuData?.text ?? ""
                    verticalAlignment: Text.AlignVCenter
                    color: {
                        let color = Qt.color(ShellSettings.colors.active);

                        if (!root.menuData?.enabled)
                            return color.darker(2);

                        // if (entryArea.containsMouse)
                        //     return Qt.color(ShellSettings.colors["inverse_primary"]);

                        return color;
                    }

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                Item {
                    visible: root.rootMenu.rightItem
                    Layout.preferredHeight: 20
                    Layout.preferredWidth: 20
                    Layout.rightMargin: 5

                    Widgets.IconButton {
                        id: arrowButton
                        visible: root.menuData?.hasChildren ?? false
                        activeRectangle: false
                        source: "root:resources/general/right-arrow.svg"
                        rotation: subTrayMenu.visible ? 90 : 0
                        anchors.fill: parent

                        Behavior on rotation {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutCubic
                            }
                        }

                        onClicked: {
                            root.expanded = !root.expanded;
                        }
                    }
                }
            }
        }
    }

    WrapperRectangle {
        id: subTrayMenu
        color: ShellSettings.colors.surface_container
        radius: 8
        visible: false
        Layout.fillWidth: true

        QsMenuOpener {
            id: menuOpener
            menu: root.menuData
        }

        ColumnLayout {
            id: subTrayContainer
            spacing: 2
            Layout.fillWidth: true

            Repeater {
                model: menuOpener.children

                delegate: BoundComponent {
                    id: subMenuEntry
                    source: "TrayMenuItem.qml"
                    Layout.fillWidth: true
                    required property var modelData
                    property var rootMenu: root.rootMenu
                }
            }
        }
    }
}
