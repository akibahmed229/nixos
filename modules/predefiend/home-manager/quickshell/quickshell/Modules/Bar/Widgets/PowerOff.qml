import Quickshell
import QtQuick
import QtQuick.Controls
import Quickshell.Io
import QtQuick.Layouts
import qs.Modules.Wlogout

RowLayout {
    spacing: 5
    Layout.rightMargin: 10

    Button {
        id: poweroff
        icon.source: "./Icons/power-off.svg"
        background: null
        font.pixelSize: 22

        onClicked: wlogoutProcess.running = true
    }

    Process {
        id: wlogoutProcess
        command: ["sh", "-c", "quickshell -p ~/.config/quickshell/Modules/Wlogout/WLogoutShell.qml"]
    }
}
