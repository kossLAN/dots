import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.lockscreen as Lockscreen
import qs.services.niri

Scope {
    id: root

    property var minsToLock: 10
    property var minsToMonitorOff: 5

    Component.onCompleted: console.info("Started IdleHandler")

    IdleMonitor {
        id: lock
        respectInhibitors: true
        timeout: root.minsToLock * 60

        onIsIdleChanged: {
            if (isIdle)
                Lockscreen.Controller.api.lock();
        }
    }

    IdleMonitor {
        id: monitorOff
        respectInhibitors: true
        timeout: root.minsToMonitorOff * 60

        onIsIdleChanged: {
            if (isIdle)
                Niri.dpms(false);
        }
    }
}
