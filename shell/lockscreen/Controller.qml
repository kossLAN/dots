pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Singleton {
    id: root

    PersistentProperties {
        id: persist
        property bool locked: false
    }

    IpcHandler {
        target: "lockscreen"

        function lock(): void {
            persist.locked = true;
        }
    }

    LockContext {
        id: passwordContext

        onUnlocked: persist.locked = false
    }

    WlSessionLock {
        id: lock

        locked: persist.locked

        WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                context: passwordContext
            }
        }
    }

    function init() {}
}
