import Quickshell
import QtQuick
import QtQuick.Controls
import Quickshell.Io

Row {
    id: root
    rightPadding: 10

    Process {
        id: wlogoutProcess
        command: ["quickshell", "-p", "/home/akib/.config/quickshell/Modules/Wlogout/WLogoutShell.qml"]
    }
    Button {
        id: poweroff
        text: "⏻"
        background: null
        font.pixelSize: 22
        onClicked: wlogoutProcess.running = true
    }
}
