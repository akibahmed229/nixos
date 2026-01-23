// system imports
pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// custom module imports
import qs.Modules.LockScreen as LockScreen

Singleton {
    id: root

    IpcHandler {
        target: "lockscreen"

        function lock(): void {
            lock.locked = true;
        }
    }

    WlSessionLock {
        id: lock
        locked: false

        WlSessionLockSurface {
            id: lockSurface
            LockSurface {
                anchors.fill: parent
                context: lockContext
            }
        }
    }

    // This stores all the information shared between the lock surfaces on each screen.
    LockContext {
        id: lockContext
        onUnlocked: lock.locked = false
    }

    // Empty function to define first reference to singleton
    function init() {
    }
}
