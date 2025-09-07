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
        radius: 0
    }

    // Modified Rectangle for the subtle bottom border
    Rectangle {
        anchors {
            left: bar.left
            right: bar.right
            bottom: bar.bottom
        }
        height: 1 // Keep it very thin, possibly even 0.5 if supported and desired
        color: "#282828" // A very dark gray, slightly lighter than #1a1a1a but still dark. You can experiment with adding transparency, e.g., "#282828C0"
        radius: 0
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
        QQC.Button {
            id: notifToggle
            text: "🔔"
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
        CpuMem {}
        SysTray {}
    }
}
