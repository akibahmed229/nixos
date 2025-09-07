//@ pragma UseQApplication
import Quickshell
import QtQuick
import qs.Modules.Bar
import qs.Modules.VolumeOsd

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
}
