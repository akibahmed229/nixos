// system imports
import QtQuick
import QtQuick.Controls
import Quickshell.Io
import QtQuick.Layouts

// custom imports
import qs.Modules.Wlogout as Wlogout

// Power button + logout/power panel
RowLayout {
    spacing: 5

    Button {
        id: poweroff
        icon.source: "./Icons/power-off.svg" // power icon
        background: null
        font.pixelSize: 22

        // toggle Wlogout panel on click
        onPressed: () => {
            Wlogout.Controller.isOpen = true;
        }
    }
}
