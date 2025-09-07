import Quickshell
import QtQuick // For SystemPalette
import QtQuick.Layouts
import qs.Modules.Bar.Widgets
import QtQuick.Controls as QQC
import Quickshell.Io

PanelWindow {
    id: panel
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: 30
    margins {
        top: 0
        right: 0
        left: 0
    }

    Rectangle {
        id: bar
        anchors.fill: parent
        color: "#282828"
        radius: 0
    }

    // Main Block
    // keep the RowLayout for left/right only (no WorkSpaces in the RowLayout)
    RowLayout {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        spacing: 0

        // Left Blocks
        RowLayout {
            id: leftBlocks
            spacing: 10
            DateTime {}
            NotificationIcon {}
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
