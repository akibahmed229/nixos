//@ pragma UseQApplication
import Quickshell
import QtQuick
import "./Modules/Bar/"

ShellRoot {
    id: root

    Loader {
        active: true
        sourceComponent: Bar {}
    }
}
