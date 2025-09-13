//@ pragma UseQApplication
// system imports
import Quickshell
import QtQuick

// custom module imports
import qs.Modules.Bar
import qs.Modules.VolumeOsd
import qs.Modules.Notification
import qs.Modules.Wlogout as Wlogout
import qs.Modules.LockScreen as LockScreen

// Root of the entire shell setup
ShellRoot {
    id: root

    // --- Top bar with widgets (CPU, clock, tray, etc.)
    Loader {
        active: true
        sourceComponent: Bar {}
    }

    // --- On-screen display for volume changes
    Loader {
        active: true
        sourceComponent: VolumeOsd {}
    }

    // --- Notification panel for system/app messages
    Loader {
        active: true
        sourceComponent: NotificationPanel {}
    }

    // --- Logout/Shutdown/Restart menu (Wlogout replacement) & Screen Lock
    Component.onCompleted: () => {
        Wlogout.Controller.init();
        LockScreen.Controller.init();
    }
}
