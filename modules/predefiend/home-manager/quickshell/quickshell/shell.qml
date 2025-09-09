//@ pragma UseQApplication
//system import
import Quickshell
import QtQuick

// custom import
import qs.Modules.Bar
import qs.Modules.VolumeOsd
import qs.Modules.Notification
import qs.Modules.Wlogout

ShellRoot {
    id: root

    Loader {
        active: true
        sourceComponent: Bar {}
    }
    Loader {
        active: true
        sourceComponent: VolumeOsd {}
    }
    Loader {
        active: true
        sourceComponent: NotificationPanel {}
    }
    Loader {
        active: true
        sourceComponent: WLogoutShell {}
    }
}
