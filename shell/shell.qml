//@ pragma UseQApplication
//@ pragma IconTheme Papirus-Dark

import Quickshell
import QtQuick
import qs.bar
import qs.notifications as Notifications
import qs.mpris as Mpris
import qs.volosd as VolumeOSD
import qs.settings as Settings
import qs.launcher as Launcher
import qs.lockscreen as LockScreen
import qs.wallpaper as Wallpaper
import qs.screencapture as ScreenCapture

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
