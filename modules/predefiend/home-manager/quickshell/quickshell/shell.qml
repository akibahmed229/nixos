//@ pragma UseQApplication
//system import
import Quickshell
import QtQuick

// custom import
import qs.Modules.Bar
import qs.Modules.VolumeOsd
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
        active: false
        sourceComponent: WLogoutShell {}
    }
}
