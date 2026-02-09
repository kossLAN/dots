pragma ComponentBehavior: Bound

import QtQuick

import qs
import qs.launcher
import qs.widgets

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

        SettingsManager {
            anchors {
                fill: parent
                margins: 8
            }

            model: [
                GeneralSettings {},
                WallpaperSettings {},
                MonitorSettings {},
                VolumeSettings {},
                WifiSettings {},
                BluetoothSettings {},
                DebugViewer {}
            ]
        }

        StyledRectangle {
            focus: true
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
