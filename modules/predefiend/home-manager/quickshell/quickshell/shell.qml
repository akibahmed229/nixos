//@ pragma UseQApplication
import Quickshell
import QtQuick
import "./Modules/Bar/"
import "./Modules/Volume-Osd/"

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
