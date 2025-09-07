import Quickshell
import QtQuick
import QtQuick.Controls as QQC
import Quickshell.Io

Row {
    Process {
        id: wlogoutProcess
        command: ["quickshell", "-p", "/home/akib/.config/quickshell/Modules/Wlogout/WLogoutShell.qml"]
    }
    QQC.Button {
        id: poweroff
        text: "⏻"
        background: null
        font.pixelSize: 18
        onClicked: wlogoutProcess.running = true
    }
}
