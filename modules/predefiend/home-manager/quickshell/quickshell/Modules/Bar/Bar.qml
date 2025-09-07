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

    // Modified Rectangle for the subtle bottom border
    Rectangle {
        anchors {
            left: bar.left
            right: bar.right
            bottom: bar.bottom
        }
        height: 2
        color: "#282828"
        bottomLeftRadius: 12
        bottomRightRadius: 12
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "gray"
            }
            GradientStop {
                position: 1.0
                color: "black"
            }
        }
    }

    // Main Block
    RowLayout {
        anchors.fill: parent
        spacing: 10

        // Left Side
        DateTime {}
        NotificationIcon {} // MOVED here with other right-side items

        // Spacer
        Item {
            Layout.fillWidth: true
        }

        // Center clock
        // REMOVED: anchors.centerIn: parent
        // The RowLayout and spacers will now handle centering.
        WorkSpaces {
            anchors.centerIn: parent
        }

        // Spacer
        Item {
            Layout.fillWidth: true
        }

        // Right side
        CpuMem {}
        SysTray {}
        PowerOff {}
    }
}
