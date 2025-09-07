import Quickshell
import QtQuick // For SystemPalette
import QtQuick.Layouts
import qs.Modules.Bar.Widgets
import QtQuick.Controls as QQC
import qs.Modules.Notification

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
        color: "#1a1a1a"
        radius: 0 // Remove overall radius if you only want a bottom border
        // No border properties here, to avoid any unintended borders
    }

    // Add a separate rectangle for the bottom border
    Rectangle {
        anchors {
            left: bar.left
            right: bar.right
            bottom: bar.bottom
        }
        height: 2 // Adjust border thickness as desired
        color: "#4285F4" // Google Material Blue, or choose your desired color
        radius: 0 // Ensure this border is not rounded
    }

    // Main Block
    RowLayout {
        anchors.fill: parent
        spacing: 10
        // Left Side
        WorkSpaces {}
        CpuMem {}

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
        QQC.Button {
            id: notifToggle
            text: "🔔" // bell icon (can swap for proper icon later)
            background: null
            font.pixelSize: 16
            onClicked: {
                notifPanel.visible = !notifPanel.visible;
            }
        }

        NotificationPanel {
            id: notifPanel
            text_color: "white"
        }
        SysTray {}
    }
}
