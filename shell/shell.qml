//@ pragma UseQApplication
//@ pragma IconTheme Papirus-Dark

import Quickshell
import QtQuick

import qs.bar
import qs.notifications
import qs.volosd
import qs.lockscreen
import qs.wallpaper
import qs.launcher
import qs.polkit
import qs.services.idlehandler
import qs.services.mpris

ShellRoot {
    Bar {}
    // NotificationsPopup {}
    Wallpaper {}
    VolumeOSD {}
    Polkit {}

    IdleHandler {
        minsToLock: 15
        minsToMonitorOff: 5
    }

    Component.onCompleted: {
        Notifications.init();
        Launcher.init();
        LockScreen.init();
        Mpris.init();
    }
}
