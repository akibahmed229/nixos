// system imports
import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts

// custom imports
import qs.Modules.Bar.Widgets   // bar widgets (CPU, datetime, tray, etc.)
import qs.Settings              // theme settings (colors, borders, etc.)
import qs.Components            // reusable components (margins, etc.)

// Main top bar window
PanelWindow {
    id: panel
    color: Theme.get.transparent        // keep window transparent
    implicitHeight: 32                  // bar height

    anchors {
        top: true       // stick to top
        left: true
        right: true
    }

    margins {
        top: 4
        right: 8
        left: 8
    }

    // Rounded background rectangle (styled via Theme.qml)
    Rectangle {
        id: bar
        radius: 6
        color: Theme.get.bgColor
        border.color: Theme.get.buttonBorder
        border.width: 2
        anchors.fill: parent

        // --- Main layout (split left & right sections)
        RowLayout {
            id: mainBlock
            spacing: 0
            anchors.fill: parent

            // --- Left section of bar
            RowLayout {
                id: leftBlocks
                spacing: 10
                MarginLeft {}          // padding
                NotificationIcon {}    // shows system/app notifications
                DateTime {}            // clock widget
                WindowTitle {}         // current window title
            }

            Item {
                Layout.fillWidth: true
            }  // spacer to push right side

            // --- Right section of bar
            RowLayout {
                id: rightBlocks
                spacing: 10
                CpuMem {}              // CPU + memory usage
                SysTray {}             // system tray icons
                PowerOff {}            // shutdown/logout button
                MarginRight {}         // padding
            }
        }

        // --- Centered workspace indicator (overlays above left/right blocks)
        WorkSpaces {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            // must not use Layout.* to avoid conflicts
        }
    }
}
