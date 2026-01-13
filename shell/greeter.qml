pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Greetd
import qs.lockscreen

ShellRoot {
    id: root

    GreeterContext {
        id: context

        onLaunch: {
            lock.locked = false;
<<<<<<< HEAD
            const session = Quickshell.env("GREETER_SESSION") || "start-hyprland";
=======
            const session = Quickshell.env("GREETER_SESSION") || "niri-session";
>>>>>>> 0f59023 (bar: convert workspaces to niri)
            Greetd.launch([session]);
        }
    }

    WlSessionLock {
        id: lock
        locked: true

        WlSessionLockSurface {
            LockSurface {
                state: context.state

                wallpaper: Quickshell.env("GREETER_WALLPAPER") || "root:resources/wallpapers/wallhaven-96y9qk.jpg"
                anchors.fill: parent
            }
        }
    }
}
