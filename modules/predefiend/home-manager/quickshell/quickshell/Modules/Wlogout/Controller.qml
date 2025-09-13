// system imports
pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

// custom module imports
import qs.Modules.Wlogout as Wlogout

Singleton {
    id: root

    property bool isOpen: false

    IpcHandler {
        target: "wlogout"

        function open() {
            root.isOpen = true;
        }

        function close() {
            root.isOpen = false;
        }

        function toggle() {
            root.isOpen = !root.isOpen;
        }
    }

    LazyLoader {
        active: root.isOpen
        Wlogout.WLogoutShell {}
    }

    // Empty function to define first reference to singleton
    function init() {
    }
}
