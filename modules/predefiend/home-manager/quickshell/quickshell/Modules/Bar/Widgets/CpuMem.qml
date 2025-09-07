import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts

RowLayout {
    spacing: 12
    Text {
        id: cpuLabel
        text: "Cpu: N/A%"
        color: "#fb4934"
        font.family: "Inter, sans-serif"
    }

    // Text {
    //     id: cpuTempLabel
    //     text: " : N/A%"
    //     color: "orange"
    // }

    Text {
        id: memLabel
        text: "Mem: N/A"
        color: "#b8bb26"
        font.family: "Inter, sans-serif"
    }

    Process {
        id: cpuProc
        command: ["bash", "-c", "top -bn1 | awk '/Cpu/ { print $2}'"]

        stdout: StdioCollector {
            onStreamFinished: cpuLabel.text = "cpu: " + text.trim() + "%"
        }
    }

    // Process {
    //     id: cpuTempProc
    //     command: ["bash", "-c", "sensors | grep Package | awk '{print $4}'"]

    //     stdout: StdioCollector {
    //         onStreamFinished: cpuTempLabel.text = " : " + text.trim() + "%"
    //     }
    // }

    Process {
        id: memProc
        command: ["sh", "-c", "free -m | awk '/Mem:/ {print int($3/$2 * 100)}'"]
        stdout: StdioCollector {
            onStreamFinished: memLabel.text = "Mem: " + text.trim() + "%"
        }
    }
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true;
            memProc.running = true;
            // cpuTempProc.running = true;
        }
    }
}
