//@ pragma UseQApplication
//@ pragma IconTheme Papirus-Dark

import Quickshell
import QtQuick
import "bar" as Bar
import "notifications" as Notifications
import "volume-osd" as VolumeOSD
import "settings" as Settings
import "launcher" as Launcher
import "wallpaper" as Wallpaper
import "screencapture" as ScreenCapture

ShellRoot {
    Component.onCompleted: {
        Launcher.Controller.init();
        Settings.Controller.init();
        Notifications.NotificationCenter.init();
        ScreenCapture.Controller.init();
    }

    Variants {
        model: Quickshell.screens

        Scope {
            id: scope
            property var modelData

            Bar.Bar {
                screen: scope.modelData
            }
        }
    }

    Notifications.Controller {}
    VolumeOSD.Controller {}
    Wallpaper.Controller {}
}
