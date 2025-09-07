import Quickshell
import QtQuick
import QtQuick.Controls
import Quickshell.Io
import qs.Modules.Wlogout

Row {
    id: root
    rightPadding: 10

    Process {
        id: wlogoutProcess
        command: ["sh", "-c", "quickshell -p ~/.config/quickshell/Modules/Wlogout/WLogoutShell.qml"]
    }
    Button {
        id: poweroff
        text: "⏻"
        font.pixelSize: 22
        background: null

        contentItem: Text {
            text: poweroff.text
            color: "#ebdbb2"
            font.pixelSize: poweroff.font.pixelSize
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        onClicked: wlogoutProcess.running = true
    }
}
