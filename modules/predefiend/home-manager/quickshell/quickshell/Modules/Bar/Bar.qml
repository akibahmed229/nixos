import Quickshell
import QtQuick // For SystemPalette
import QtQuick.Layouts
import "./Widgets/"

PanelWindow {
    id: panel

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 30

    margins {
        top: 8
        right: 10
        left: 10
    }

    Rectangle {
        id: bar
        anchors.fill: parent
        color: "#1a1a1a"
        radius: 12
        border.color: "#333333"
        border.width: 3
    }

    // Main Block
    RowLayout {
        anchors.fill: parent
        spacing: 10

        // Left Side
        WorkSpaces {}

        // Spacer
        Item {
            Layout.fillWidth: true
        }

        // Center clock
        DateTime {
            anchors.centerIn: parent
        }

        // Spacer
        Item {
            Layout.fillWidth: true
        }
        // Right side

        CpuMem {}
        SysTray {}
    }
}
