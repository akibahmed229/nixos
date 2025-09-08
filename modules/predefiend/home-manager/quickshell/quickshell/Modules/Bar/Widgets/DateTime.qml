import Quickshell.Io
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    anchors {
        leftMargin: 16
    }

    Text {
        id: clock
        color: "#ebdbb2"
        font.family: "Inter, sans-serif"
    }

    Process {
        id: dateProc

        // We pass a format string to the 'date' command
        command: ["date", "+%A %I:%M %P, %B %e"]
        running: true

        stdout: StdioCollector {
            // .trim() removes any potential extra whitespace from the command's output
            onStreamFinished: clock.text = this.text.trim()
        }
    }

    // use a timer to rerun the process at an interval
    Timer {
        // 1000 milliseconds is 1 second
        interval: 1000

        // start the timer immediately
        running: true

        // run the timer again when it ends
        repeat: true

        // when the timer is triggered, set the running property of the
        // process to true, which reruns it if stopped.
        onTriggered: dateProc.running = true
    }
}
