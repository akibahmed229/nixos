// system import
import QtQuick
import QtQuick.Controls
import Quickshell.Io
import QtQuick.Layouts

// custom import
import qs.Modules.Wlogout

RowLayout {
    spacing: 5
    Layout.rightMargin: 10

    Button {
        id: poweroff
        icon.source: "./Icons/power-off.svg"
        background: null
        font.pixelSize: 22

        onClicked: wlogoutPanel.visible = !wlogoutPanel.visible
    }

    // The Wlogout panel that appears when the icon is clicked
    WLogoutShell {
        id: wlogoutPanel
    }
}
