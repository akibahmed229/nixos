import Quickshell
import QtQuick // For SystemPalette
import QtQuick.Layouts
import qs.Modules.Bar.Widgets
import QtQuick.Controls as QQC
import Quickshell.Io

PanelWindow {
    id: panel
    color: "transparent"
    implicitHeight: 32

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: 4
        right: 8
        left: 8
    }

    // Bar
    Rectangle {
        id: bar
        radius: 6
        color: "#282828"

        border.color: "transparent"
        border.width: 2

        anchors.fill: parent

        // Main Block
        // keep the RowLayout for left/right only (no WorkSpaces in the RowLayout)
        RowLayout {
            id: mainBlock
            spacing: 0

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }

            // Left Blocks
            RowLayout {
                id: leftBlocks
                spacing: 10

                NotificationIcon {}
                DateTime {}
                WindowTitle {}
            }

            Item {
                Layout.fillWidth: true
            } // push right side

            // Right Blocks
            RowLayout {
                id: rightBlocks
                spacing: 10

                CpuMem {}
                SysTray {}
                PowerOff {}
            }
        }

        // overlay WorkSpaces centered
        WorkSpaces {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            // ensure it doesn't use Layout.* properties
        }
    }
}
