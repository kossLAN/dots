pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

import qs
import qs.launcher
import qs.widgets

// Stupid LSP complains about this import THAT is required
// because I use a loader for the component
import qs.launcher.settings.monitor
import qs.launcher.settings.volume

LauncherBacker {
    id: root

    icon: "settings"

    switcherParent: switcherParent

    content: Item {
        id: menu
        implicitWidth: 800
        implicitHeight: 600

        RowLayout {
            id: layoutRoot
            spacing: 0
            anchors.fill: parent

            Layout.fillWidth: true
            Layout.fillHeight: true

            property int currentPageIndex: 0

            property var pageDefinitions: [
                {
                    title: "General",
                    description: "General settings",
                    source: "GeneralSettings.qml",
                    icon: "applications-system"
                },
                {
                    title: "Monitors",
                    description: "Manage monitor settings",
                    source: "monitor/MonitorSettings.qml",
                    icon: "video-display"
                },
                {
                    title: "Wallpapers",
                    description: "Change your wallpaper",
                    source: "WallpaperPicker.qml",
                    icon: "preferences-desktop-wallpaper"
                },
                {
                    title: "Volume",
                    description: "Manage audio devices and applications",
                    source: "volume/VolumeSettings.qml",
                    icon: "applications-multimedia"
                },
                {
                    title: "WiFi",
                    description: "Manage WiFi networks",
                    source: "WifiSettings.qml",
                    icon: "network-wireless"
                },
                {
                    title: "Bluetooth",
                    description: "Manage Bluetooth devices",
                    source: "BluetoothSettings.qml",
                    icon: "preferences-system-bluetooth"
                }
            ]

            Item {
                Layout.preferredWidth: 32
                Layout.fillHeight: true

                StyledListView {
                    clip: true
                    spacing: 4
                    model: layoutRoot.pageDefinitions

                    anchors.fill: parent
                    anchors.margins: 4

                    delegate: StyledMouseArea {
                        id: entry

                        required property int index
                        required property var modelData

                        implicitWidth: ListView.view.width
                        implicitHeight: ListView.view.width

                        radius: 6
                        onClicked: layoutRoot.currentPageIndex = index
                        checked: layoutRoot.currentPageIndex === index

                        IconImage {
                            source: Quickshell.iconPath(entry.modelData.icon, "application-x-executable")
                            anchors.fill: parent
                        }
                    }
                }
            }

            Item {
                id: pageStack

                Layout.fillWidth: true
                Layout.fillHeight: true

                Loader {
                    anchors.fill: parent
                    active: true
                    source: layoutRoot.pageDefinitions[layoutRoot.currentPageIndex].source
                }

                StyledRectangle {
                    // id: switcherParent
                    color: ShellSettings.colors.active.mid
                    implicitHeight: switcherParent.implicitHeight + 8
                    implicitWidth: switcherParent.implicitWidth + 8

                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                        margins: 16
                    }

                    Item {
                        id: switcherParent
                        anchors.centerIn: parent
                        implicitWidth: childrenRect.width
                        implicitHeight: childrenRect.height
                    }
                }
            }
        }
    }
}
