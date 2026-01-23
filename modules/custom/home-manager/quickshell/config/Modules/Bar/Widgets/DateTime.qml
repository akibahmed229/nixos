// system imports
import QtQuick
import Quickshell.Io
import QtQuick.Layouts

// custom imports
import qs.Settings   // theme colors

// Container for date + time widget
RowLayout {
    id: root
    anchors.leftMargin: 16   // spacing from left side

    // --- Clock text display ---
    Text {
        id: clock
        color: Theme.get.textColor
        font.family: "Inter, sans-serif"
        font.weight: Font.Bold
    }

    // --- Date/time fetch process ---
    Process {
        id: dateProc
        // Format string for `date`:
        // Example output: "Monday 03:15 pm, September  7"
        command: ["date", "+%A %I:%M %P, %B %e"]
        running: true

        stdout: StdioCollector {
            // Assign formatted date to clock text
            onStreamFinished: clock.text = this.text.trim()
        }
    }

    // --- Timer to refresh clock every second ---
    Timer {
        interval: 1000      // 1 second
        running: true       // start immediately
        repeat: true        // keep looping

        onTriggered: dateProc.running = true
    }
}
