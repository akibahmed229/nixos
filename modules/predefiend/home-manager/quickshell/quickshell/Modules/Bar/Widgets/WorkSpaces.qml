// system imports
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

// custom imports
import qs.Settings

// Workspace indicator row (e.g., | 1 | 2 | 3 | 4 | 5 | )
Row {
    id: root
    spacing: 8 // space between workspace items

    Repeater {
        model: Hyprland.workspaces // dynamically render all Hyprland workspaces

        Rectangle {
            // visual box for each workspace
            width: 26
            height: 26
            radius: 6
            color: "transparent"
            border.width: 1
            border.color: modelData.active ? Theme.get.infoColor : "transparent"

            MouseArea {
                // switch to workspace on click
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + modelData.id)
            }

            Text {
                // workspace number/label
                text: modelData.id
                color: modelData.active ? Theme.get.infoColor : Theme.get.textColor
                anchors.centerIn: parent
                font.pixelSize: 14
                font.family: "Inter, sans-serif"
                font.weight: modelData.active ? Font.ExtraBold : Font.Normal
            }
        }
    }
}
