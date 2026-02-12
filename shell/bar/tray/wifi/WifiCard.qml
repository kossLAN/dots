import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import Quickshell.Widgets
import qs.widgets
import qs

Item {
    id: root

    required property WifiNetwork network

    RowLayout {
        spacing: 2
        anchors.fill: parent

        IconImage {
            source: {
                if (!root.network)
                    return Quickshell.iconPath("network-wireless-100");

                const strength = root.network.signalStrength;

                if (strength >= 0.75)
                    return Quickshell.iconPath("network-wireless-80");
                if (strength >= 0.5)
                    return Quickshell.iconPath("network-wireless-60");
                if (strength >= 0.25)
                    return Quickshell.iconPath("network-wireless-40");

                return Quickshell.iconPath("network-wireless-20");
            }

            Layout.preferredWidth: this.height
            Layout.fillHeight: true
            Layout.margins: 4
        }

        ColumnLayout {
            spacing: 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter

            StyledText {
                text: root.network && root.network.name ? root.network.name : "Unknown Network"
                color: ShellSettings.colors.active.windowText
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
            }

            StyledText {
                text: {
                    if (!root.network)
                        return "Unknown";
                    if (root.network.stateChanging)
                        return "Connecting...";
                    if (root.network.connected)
                        return "Connected";
                    if (root.network.known)
                        return "Saved";

                    return "Available";
                }
                color: ShellSettings.colors.active.windowText.darker(1.5)
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
                enabled: root.network !== null

                onClicked: {
                    if (root.network) {
                        if (root.network.connected) {
                            root.network.disconnect();
                        } else {
                            root.network.connect();
                        }
                    }
                }

                IconImage {
                    source: {
                        if (root.network && root.network.connected) {
                            return Quickshell.iconPath("network-disconnect-symbolic");
                        } else {
                            return Quickshell.iconPath("network-connect-symbolic");
                        }
                    }

                    anchors {
                        fill: parent
                        margins: 2
                    }
                }
            }

            // StyledMouseArea {
            //     enabled: root.network !== null && root.network.known
            //     visible: root.network !== null && root.network.known
            //
            //     onClicked: {
            //         if (root.network) {
            //             root.network.forget();
            //         }
            //     }
            //
            //     Layout.preferredWidth: this.height
            //     Layout.fillHeight: true
            //
            //     IconImage {
            //         source: Quickshell.iconPath("edit-delete")
            //
            //         anchors {
            //             fill: parent
            //             margins: 2
            //         }
            //     }
            // }
        }
    }
}
