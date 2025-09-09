// system import
import QtQuick
import Quickshell

WLogout {
    LogoutButton {
        command: "quickshell -p ~/.config/quickshell/Modules/LockScreen/shell.qml"
        keybind: Qt.Key_L  // Changed from K to L for Lock
        text: "Lock"
        icon: "lock"
    }
    LogoutButton {
        command: "uwsm stop"  // Or loginctl terminate-session $XDG_SESSION_ID for systemd
        keybind: Qt.Key_E
        text: "Logout"
        icon: "logout"
    }
    LogoutButton {
        command: "systemctl suspend"
        keybind: Qt.Key_S  // Changed to S for Suspend (avoid conflicts)
        text: "Suspend"
        icon: "suspend"
    }
    LogoutButton {
        command: "systemctl hibernate"
        keybind: Qt.Key_H
        text: "Hibernate"
        icon: "hibernate"
    }
    LogoutButton {
        command: "systemctl poweroff"
        keybind: Qt.Key_P  // Changed from K to P for Poweroff
        text: "Shutdown"
        icon: "shutdown"
    }
    LogoutButton {
        command: "systemctl reboot"
        keybind: Qt.Key_R
        text: "Reboot"
        icon: "reboot"
    }
}
