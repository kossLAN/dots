pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs

Singleton {
    id: root
    property alias api: ipc

    PersistentProperties {
        id: persist
        property bool locked: false
    }

    IpcHandler {
        id: ipc
        target: "lockscreen"

        function lock(): void {
            persist.locked = true;
        }
    }

    LockContext {
        id: context

        Connections {
            target: context.state

            function onUnlocked() {
                persist.locked = false;
            }
        }
    }

    WlSessionLock {
        id: lock
        locked: persist.locked

        WlSessionLockSurface {
            LockSurface {
                state: context.state
                wallpaper: ShellSettings.settings.wallpaperUrl
                anchors.fill: parent
            }
        }
    }

    function init() {
    }
}
