// system imports
import QtQuick
import Quickshell.Io
import QtQuick.Layouts

// custom imports
import qs.Settings    // theme colors

// Root container to hold both the layout and the overlay MouseArea
Item {
    id: root

    // The RowLayout now becomes a child, responsible for positioning the visible items.
    RowLayout {
        id: contentLayout // Give it an ID to reference its size
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
    }

    // Set the root item's size to match the layout's implicit size.
    // This makes the component size itself correctly based on its content.
    implicitWidth: contentLayout.implicitWidth
    implicitHeight: contentLayout.implicitHeight

    // The MouseArea is now a sibling of the layout, not a child.
    // It fills the root Item, covering the layout without interfering with it.
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            btopLauncher.running = true;
        }
    }

    // Non-visual components can remain at the root level.
    // --- Process to launch btop on click ---
    Process {
        id: btopLauncher
        command: ["bash", "-c", "$TERMINAL -e btop"]
    }

    // --- CPU usage process ---
    Process {
        id: cpuProc
        command: ["bash", "-c", "top -bn1 | awk '/Cpu/ { print $2}'"]

        stdout: StdioCollector {
            onStreamFinished: cpuLabel.text = "cpu: " + text.trim() + "%"
        }
    }

    // --- Memory usage process ---
    Process {
        id: memProc
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
            cpuProc.running = true;
            memProc.running = true;
        }
    }
}
