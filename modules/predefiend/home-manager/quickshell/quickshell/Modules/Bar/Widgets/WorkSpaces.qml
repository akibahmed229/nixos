import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Hyprland

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
            border.color: modelData.active ? "#8ec07c" : "transparent"
            border.width: 1

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + modelData.id)
            }

            Text {
                text: modelData.id
                anchors.centerIn: parent
                color: modelData.active ? "#8ec07c" : "#ebdbb2"
                font.pixelSize: 14
                font.family: "Inter, sans-serif"
                font.weight: modelData.active ? Font.ExtraBold : Font.Normal
            }
        }
    }
}
