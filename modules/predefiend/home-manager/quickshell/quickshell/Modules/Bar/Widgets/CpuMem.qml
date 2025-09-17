// system imports
import QtQuick
import Quickshell.Io
import QtQuick.Layouts

// custom imports
import qs.Settings    // theme colors

// Layout container for CPU + Memory stats
RowLayout {
    spacing: 12

    // --- CPU usage label ---
    Text {
        id: cpuLabel
        text: "cpu: N/A%"
        color: Theme.get.errorColor    // red tone for CPU
        font.family: "Inter, sans-serif"
    }

    // --- Memory usage label ---
    Text {
        id: memLabel
        text: "mem: N/A%"
        color: Theme.get.successColor // green tone for RAM
        font.family: "Inter, sans-serif"
    }

    // --- Process to launch btop on click ---
    Process {
        id: btopLauncher
        command: ["bash", "-c", "$TERMINAL -e btop"]
        // This process is only run when triggered by the MouseArea
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true // Enable hover events
        cursorShape: Qt.PointingHandCursor // Change cursor to a hand on hover

        onClicked: {
            // Run the btopLauncher process when the area is clicked
            btopLauncher.running = true;
        }
    }

    // --- CPU usage process ---
    Process {
        id: cpuProc
        // Run top once (-bn1) and extract CPU usage from its output
        command: ["bash", "-c", "top -bn1 | awk '/Cpu/ { print $2}'"]

        stdout: StdioCollector {
            onStreamFinished: cpuLabel.text = "cpu: " + text.trim() + "%"
        }
    }

    // --- Memory usage process ---
    Process {
        id: memProc
        // free -m → get Mem line → calculate percentage
        command: ["sh", "-c", "free -m | awk '/Mem:/ {print int($3/$2 * 100)}'"]

        stdout: StdioCollector {
            onStreamFinished: memLabel.text = "mem: " + text.trim() + "%"
        }
    }

    // --- Timer to refresh every 1s ---
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true;    // refresh CPU usage
            memProc.running = true;    // refresh memory usage
        }
    }
}
