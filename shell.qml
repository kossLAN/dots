//@ pragma UseQApplication
//@ pragma IconTheme Papirus-Dark

import Quickshell
import QtQuick
import "bar" as Bar
import "notifications" as Notifications
import "mpris" as Mpris
import "volume-osd" as VolumeOSD
import "settings" as Settings
import "launcher" as Launcher
import "lockscreen" as LockScreen
import "wallpaper" as Wallpaper
import "screencapture" as ScreenCapture

ShellRoot {
    // Singleton's that need to be loaded in some way
    Component.onCompleted: {
        Launcher.Controller.init();
        Settings.Controller.init();
        ScreenCapture.Controller.init();
        Mpris.Controller.init();
        Notifications.NotificationCenter.init();
    }

    // Elements that need context from all screens
    Variants {
        model: Quickshell.screens

        Scope {
            id: scope
            property var modelData

            Bar.Bar {
                screen: scope.modelData
            }

            LockScreen.Controller {}
        }
    }

    // On activation components 
    Notifications.Controller {}
    VolumeOSD.Controller {}

    // this is an exception...
    Wallpaper.Controller {}
}
