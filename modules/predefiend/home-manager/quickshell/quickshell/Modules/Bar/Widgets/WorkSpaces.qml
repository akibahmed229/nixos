import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Hyprland

Row {
    id: root // | 1 | 2 | 3 | 4 | 5 |

    anchors {
        leftMargin: 16
    }

    spacing: 8

    Repeater {
        model: Hyprland.workspaces
        Rectangle {
            width: 32
            height: 24
            radius: 4
            color: modelData.active ? "#4a9eff" : "#333333"
            border.color: "#555555"
            border.width: 2

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + modelData.id)
            }

            Text {
                text: modelData.id
                anchors.centerIn: parent
                color: modelData.active ? "#ffffff" : "#5cccc9"
                font.pixelSize: 12
                font.family: "Inter, sans-serif"
            }
        }
    }
}
