// system import
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

// custom import
import qs.Settings

Row {
    id: root // | 1 | 2 | 3 | 4 | 5 |
    spacing: 8

    Repeater {
        model: Hyprland.workspaces

        Rectangle {
            width: 26
            height: 26
            radius: 6
            color: "transparent"
            border.width: 1
            border.color: modelData.active ? Theme.get.infoColor : "transparent"

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + modelData.id)
            }

            Text {
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
