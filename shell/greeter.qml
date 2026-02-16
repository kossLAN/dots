pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Greetd
import qs
import qs.lockscreen
import qs.services.niri

ShellRoot {
    id: root

    GreeterContext {
        id: context

        onLaunch: {
            lock.locked = false;
            const session = Quickshell.env("GREETER_SESSION") || "niri-session";
            Greetd.launch([session]);
        }
    }

    WlSessionLock {
        id: lock
        locked: true

        WlSessionLockSurface {
            LockSurface {
                state: context.state
                wallpaper: ShellSettings.greeterWallpaper
                anchors.fill: parent
            }
        }
    }

    // Try to load Niri monitor config as configured
    Component.onCompleted: {
        Niri.reloadMonitorConfig();
    }
}
