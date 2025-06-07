pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Greetd
import "lockscreen"

ShellRoot {
    id: root

    GreeterContext {
        id: context

        onLaunch: {
            lock.locked = false;
            Greetd.launch(["hyprland"]);
        }
    }

    WlSessionLock {
        id: lock
        locked: true

        WlSessionLockSurface {
            LockSurface {
                state: context.state

                // TODO: env var for wallpaper
                wallpaper: "root:resources/wallpapers/wallhaven-96y9qk.jpg"
                anchors.fill: parent
            }
        }
    }
}
