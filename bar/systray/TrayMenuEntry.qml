import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

ColumnLayout {
    id: root
    required property var menuData
    signal interacted

    WrapperRectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 25
        radius: 6
        color: {
            if (!root.menuData?.enabled)
                return "transparent";

            if (entryArea.containsMouse)
                return ShellSettings.settings.colors["primary"];

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
                        let color = Qt.color(ShellSettings.settings.colors["inverse_surface"]);

                        if (!root.menuData?.enabled)
                            return color.darker(2);

                        if (entryArea.containsMouse)
                            return Qt.color(ShellSettings.settings.colors["inverse_primary"]);

                        return color;
                    }

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Connections {
                        target: root.menuData

                        function onTextChanged() {
                            console.log("Hi");
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Item {
                    Layout.preferredHeight: 20
                    Layout.preferredWidth: 20
                    Layout.rightMargin: 5
                }
            }
        }
    }

    WrapperRectangle {
        id: subTrayMenu
        color: ShellSettings.settings.colors["surface_container"]
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
                    source: "TrayMenu.qml"
                    Layout.fillWidth: true
                    required property var modelData
                }
            }
        }
    }
}
