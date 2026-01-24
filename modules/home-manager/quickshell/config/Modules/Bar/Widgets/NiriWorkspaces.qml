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

    // Property holding current WorkSpace value
    property var currentWorkSpace: ({
            idx: "",
            workspaceName: ""
        })

    // Data model populated by getWorkspaces process
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

    // The model that getWorkspaces fills
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
                    var json = JSON.parse(text.trim());
                    var newFocusedIdx = -1;

                    // Filter for active workspaces and find the new focused index
                    var activeWorkspaces = json.filter(ws => ws.active_window_id !== null || ws.is_active);
                    for (var i = 0; i < activeWorkspaces.length; ++i) {
                        if (activeWorkspaces[i].is_focused) {
                            newFocusedIdx = activeWorkspaces[i].idx;
                            break;
                        }
                    }

                    // --- OPTIMIZATION ---
                    // Only update the model if the focused workspace has changed. This avoids expensive UI rebuilds.
                    if (newFocusedIdx.toString() !== root.currentWorkSpace.idx) {
                        // Update the current workspace tracker
                        root.currentWorkSpace.idx = newFocusedIdx.toString();

                        // Rebuild the model
                        workspaceModel.clear();
                        activeWorkspaces.sort((a, b) => a.idx - b.idx);
                        for (i = 0; i < activeWorkspaces.length; ++i) {
                            workspaceModel.append({
                                idx: activeWorkspaces[i].idx,
                                workspaceName: activeWorkspaces[i].name || "",
                                is_focused: activeWorkspaces[i].is_focused
                            });
                        }
                    }
                } catch (e) {
                    console.error("Failed to parse Niri workspaces JSON:", e);
                }
            }
        }
    }

    // Timer to periodically refresh workspaces.
    Timer {
        interval: 150
        running: true
        repeat: true
        onTriggered: {
            getWorkspaces.running = true;
        }
    }

    Component.onCompleted: getWorkspaces.running = true // Initial fetch
}
