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
    color: Theme.get.transparent
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

    // bar property
    property string currentDesktop: "niri"

    Rectangle {
        id: bar
        radius: 6
        color: Theme.get.bgColor
        border.color: Theme.get.buttonBorder
        border.width: 2
        anchors.fill: parent

        RowLayout {
            id: mainBlock
            spacing: 0
            anchors.fill: parent

            RowLayout {
                id: leftBlocks
                spacing: 10
                MarginLeft {}
                NotificationIcon {}
                DateTime {}

                // --- Conditionally load the correct workspace title indicator
                Loader {
                    sourceComponent: currentDesktop.toLowerCase().indexOf("niri") !== -1 ? niriWindowTitle : hyprlandWindowTitle
                }
            }

            Item {
                Layout.fillWidth: true
            } // spacer

            RowLayout {
                id: rightBlocks
                spacing: 10
                CpuMem {}
                SysTray {}
                PowerOff {}
                MarginRight {}
            }
        }

        // --- Conditionally load the correct workspace indicator
        // --- Centered workspace indicator (overlays above left/right blocks)
        Loader {
            anchors.centerIn: parent
            sourceComponent: currentDesktop.toLowerCase().indexOf("niri") !== -1 ? niriWorkspaces : hyprlandWorkspaces
        }
    }

    // Component
    Component {
        id: hyprlandWorkspaces
        HyprlandWorkspaces {}
    }
    Component {
        id: niriWorkspaces
        NiriWorkspaces {}
    }
    Component {
        id: hyprlandWindowTitle
        HyprlandWindowTitle {}
    }
    Component {
        id: niriWindowTitle
        Text {
            id: name
            text: qsTr("Desktop")
            color: Theme.get.infoColor
            font.weight: Font.Bold
        }
    }

    // --- detect desktop env from environment
    Process {
        id: envProcess
        command: ["sh", "-c", "echo $XDG_CURRENT_DESKTOP"]
        stdout: StdioCollector {
            onStreamFinished: {
                panel.currentDesktop = text.trim();
            }
        }
    }

    // run on startup
    Component.onCompleted: envProcess.running = true
}
