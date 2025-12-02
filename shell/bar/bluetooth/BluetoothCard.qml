import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Widgets
import qs.widgets
import qs

Item {
    id: root

    required property BluetoothDevice device

    RowLayout {
        spacing: 2
        anchors.fill: parent

        IconImage {
            source: root.device && root.device.icon ? Quickshell.iconPath(root.device.icon) : ""
            Layout.preferredWidth: this.height
            Layout.fillHeight: true
            Layout.margins: 6
        }

        ColumnLayout {
            spacing: 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter

            StyledText {
                text: root.device && root.device.name ? root.device.name : "Unknown Device"
                color: ShellSettings.colors.foreground
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
            }

            StyledText {
                text: root.device ? (root.device.connected ? "Connected" : "Disconnected") : "Unknown"
                color: ShellSettings.colors.foreground.darker(1.5)
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
            }
        }

        RowLayout {
            spacing: 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 4

            StyledMouseArea {
                Layout.preferredWidth: this.height
                Layout.fillHeight: true
                enabled: root.device !== null

                onClicked: {
                    if (root.device) {
                        if (root.device.connected) {
                            root.device.disconnect();
                        } else {
                            root.device.connect();
                        }
                    }
                }

                IconImage {
                    source: {
                        if (root.device && root.device.connected) {
                            return "image://icon/network-disconnect-symbolic";
                        } else {
                            return "image://icon/network-connect-symbolic";
                        }
                    }

                    anchors {
                        fill: parent
                        margins: 2
                    }
                }
            }

            StyledMouseArea {
                onClicked: {
                    if (root.device) {
                        root.device.forget();
                    }
                }
                enabled: root.device !== null
                Layout.preferredWidth: this.height
                Layout.fillHeight: true

                IconImage {
                    source: "image://icon/albumfolder-user-trash"

                    anchors {
                        fill: parent
                        margins: 2
                    }
                }
            }
        }
    }
}
