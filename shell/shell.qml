//@ pragma UseQApplication
//@ pragma IconTheme Papirus-Dark

import Quickshell
import QtQuick
import "bar"
import "notifications" as Notifications
import "mpris" as Mpris
import "volosd" as VolumeOSD
import "settings" as Settings
import "launcher" as Launcher
import "lockscreen" as LockScreen
import "wallpaper" as Wallpaper
import "screencapture" as ScreenCapture

ShellRoot {
    Bar {}
    Wallpaper.Controller {}
    Notifications.Controller {}
    VolumeOSD.Controller {}

    Component.onCompleted: {
        Launcher.Controller.init();
        Settings.Controller.init();
        ScreenCapture.Controller.init();
        Mpris.Controller.init();
        Notifications.NotificationCenter.init();
        LockScreen.Controller.init();
    }
}
