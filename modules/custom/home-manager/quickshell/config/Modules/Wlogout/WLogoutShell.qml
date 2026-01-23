// system import
import QtQuick
import Quickshell

WLogout {
    LogoutButton {
        command: "qs ipc call lockscreen lock"
        keybind: Qt.Key_L  // Changed from K to L for Lock
        text: "Lock"
        icon: "lock"
    }
    LogoutButton {
        command: "bash -c 'if [ \"$XDG_CURRENT_DESKTOP\" = Hyprland ]; then loginctl terminate-user \"\"; else niri msg action quit --skip-confirmation; fi'"
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
