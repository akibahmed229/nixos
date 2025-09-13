// system import
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

// custom import
import qs.Settings

// Workspace indicator row (e.g., | 1 | 2 | 3 | 4 | 5 | )
Row {
    id: root
    spacing: 8

    // data model populated by getWorkspaces process
    Repeater {
        model: workspaceModel

        // Delegate: Rectangle so children can safely use anchors
        Rectangle {
            id: workspaceBox

            // auto-size based on text width + padding
            implicitWidth: label.implicitWidth + 14   // padding left/right
            implicitHeight: label.implicitHeight + 6  // padding top/bottom

            radius: 6
            color: "transparent"
            border.width: 1
            border.color: model.is_focused ? Theme.get.infoColor : "transparent"

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    switchProcess.command = ["niri", "msg", "action", "focus-workspace", model.idx.toString()];
                    switchProcess.running = true;
                }
            }

            Text {
                id: label
                anchors.centerIn: parent
                text: model.workspaceName || model.idx
                color: model.is_focused ? Theme.get.infoColor : Theme.get.textColor
                font.pixelSize: 14
                font.family: "Inter, sans-serif"
                font.weight: model.is_focused ? Font.ExtraBold : Font.Normal
            }
        }
    }

    // the model that getWorkspaces fills
    ListModel {
        id: workspaceModel
    }
    // Process for switching workspaces
    Process {
        id: switchProcess
    }

    // Process to fetch current workspaces in JSON
    Process {
        id: getWorkspaces
        command: ["niri", "msg", "--json", "workspaces"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    workspaceModel.clear();
                    var json = JSON.parse(text.trim());

                    // Sort by idx for consistent order
                    json.sort((a, b) => a.idx - b.idx);
                    for (var i = 0; i < json.length; ++i) {
                        if (json[i].active_window_id != null) {
                            workspaceModel.append({
                                idx: json[i].idx,
                                // Rename 'name' to 'workspaceName' and fallback to "" to avoid null warnings
                                workspaceName: json[i].name || "",
                                is_focused: json[i].is_focused
                            });
                        }
                    }
                } catch (e) {
                    console.error("Failed to parse Niri workspaces JSON:", e);
                }
            }
        }
    }

    // Timer to periodically refresh workspaces (polling, as Niri has no built-in Quickshell module)
    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: getWorkspaces.running = true
    }

    Component.onCompleted: getWorkspaces.running = true // Initial fetch
}
