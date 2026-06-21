import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Settings

Scope {
    id: root

    property bool launcherOpen: false
    property string mode: "apps" // "apps" or "clipboard"
    property var rawClipboard: []

    // Unified logic to fetch list data and filter based on search input
    property var filteredItems: {
        const query = searchInput.text.toLowerCase().trim();

        if (root.mode === "apps") {
            const allApps = Array.from(DesktopEntries.applications.values);
            const visibleApps = allApps.filter(app => !app.noDisplay);
            if (query === "") {
                return visibleApps;
            }
            return visibleApps.filter(app => {
                const name = (app.name || "").toLowerCase();
                const comment = (app.comment || "").toLowerCase();
                return name.includes(query) || comment.includes(query);
            });
        } else {
            // Clipboard Mode filtering
            if (query === "") {
                return root.rawClipboard;
            }
            return root.rawClipboard.filter(item => item.toLowerCase().includes(query));
        }
    }

    // Helper process to query cliphist
    Process {
        id: cliphistScanner
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                var trimmed = text.trim();
                root.rawClipboard = trimmed !== "" ? trimmed.split("\n") : [];
            }
        }
    }

    // Process to safely decode and copy selection
    Process {
        id: cliphistDecoder
    }

    // Unified execution handler
    function executeSelection(index) {
        if (index < 0 || index >= root.filteredItems.length)
            return;
        var item = root.filteredItems[index];
        if (!item)
            return;

        if (root.mode === "apps") {
            item.execute();
        } else {
            // Decode and write back to clipboard safely using positional parameter
            cliphistDecoder.command = ["bash", "-c", "cliphist decode <<< \"$1\" | wl-copy", "--", item];
            cliphistDecoder.running = true;
        }

        root.launcherOpen = false;
        searchInput.text = "";
    }

    IpcHandler {
        target: "launcher"

        // Toggle app launcher mode
        function toggle(): void {
            root.mode = "apps";
            root.launcherOpen = !root.launcherOpen;
        }
        function show(): void {
            root.mode = "apps";
            root.launcherOpen = true;
        }

        // Toggle clipboard history manager mode
        function toggleClipboard(): void {
            root.mode = "clipboard";
            root.launcherOpen = !root.launcherOpen;
        }
        function showClipboard(): void {
            root.mode = "clipboard";
            root.launcherOpen = true;
        }

        function hide(): void {
            root.launcherOpen = false;
        }
    }

    PanelWindow {
        id: launcherWindow
        visible: root.launcherOpen

        anchors {
            top: true
            left: true
            bottom: true
            right: true
        }

        color: Theme.get.transparent
        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        // Explicitly focus searchInput on visibility toggle
        onVisibleChanged: {
            if (visible) {
                searchInput.text = "";
                searchInput.forceActiveFocus();
                appListView.currentIndex = 0;

                if (root.mode === "clipboard") {
                    cliphistScanner.running = true; // Fetch clipboard history
                }
            }
        }

        // Background Dim Overlay
        Rectangle {
            anchors.fill: parent
            color: "#80000000" // Subtle overlay opacity shadow

            // Dismiss launcher when clicking outside the container box
            MouseArea {
                anchors.fill: parent
                onClicked: root.launcherOpen = false
            }

            // Main Interactive Launcher Card
            Rectangle {
                width: 600
                height: 580
                anchors.centerIn: parent
                color: Theme.get.bgColor
                border.color: Theme.get.infoColor
                border.width: 2
                radius: 12

                // Prevent mouse clicks on the card itself from dismissing the layout
                MouseArea {
                    anchors.fill: parent
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 14

                    // Search input wrapper
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 46
                        color: Theme.get.bgColor
                        border.color: Theme.get.buttonBorder
                        border.width: 1
                        radius: 8

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8

                            Text {
                                text: root.mode === "apps" ? "☰" : "📋"
                                font.pixelSize: 22
                                color: Theme.get.whiteColor
                            }

                            TextField {
                                id: searchInput
                                Layout.fillWidth: true
                                placeholderText: root.mode === "apps" ? "Search applications..." : "Search clipboard history..."
                                placeholderTextColor: Theme.get.textColor
                                color: Theme.get.textColor
                                background: null
                                font.family: "Inter, sans-serif"
                                font.pixelSize: 15
                                selectByMouse: true

                                // Reset selection back to top cleanly when search term changes
                                onTextChanged: {
                                    appListView.currentIndex = 0;
                                }

                                // Route keyboard navigation keys downwards directly into the list view navigation handler
                                Keys.onPressed: event => {
                                    if (event.key === Qt.Key_Down) {
                                        if (appListView.currentIndex < appListView.count - 1) {
                                            appListView.currentIndex++;
                                        } else {
                                            appListView.currentIndex = 0; // Wrap around to top
                                        }
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Up) {
                                        if (appListView.currentIndex > 0) {
                                            appListView.currentIndex--;
                                        } else {
                                            appListView.currentIndex = appListView.count - 1; // Wrap around to bottom
                                        }
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Tab) {
                                        if (appListView.currentIndex < appListView.count - 1) {
                                            appListView.currentIndex++;
                                        } else {
                                            appListView.currentIndex = 0; // Wrap around to top
                                        }
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Backtab) {
                                        if (appListView.currentIndex > 0) {
                                            appListView.currentIndex--;
                                        } else {
                                            appListView.currentIndex = appListView.count - 1; // Wrap around to bottom
                                        }
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Return) {
                                        executeSelection(appListView.currentIndex);
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Escape) {
                                        root.launcherOpen = false;
                                        event.accepted = true;
                                    }
                                }
                            }
                        }
                    }

                    // Separator line
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Theme.get.buttonBorder
                        opacity: 0.3
                    }

                    // Applications / Clipboard View List
                    ListView {
                        id: appListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 4
                        model: root.filteredItems

                        delegate: Rectangle {
                            id: delegateItem
                            width: ListView.view.width
                            height: 48
                            radius: 6
                            // Highlighting currently selected element
                            color: ListView.isCurrentItem ? Theme.get.buttonHover : "transparent"
                            border.color: ListView.isCurrentItem ? Theme.get.infoColor : "transparent"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 12

                                // Application Icon (Only visible in Apps mode)
                                Image {
                                    id: appIconImage
                                    Layout.preferredWidth: 26
                                    Layout.preferredHeight: 26
                                    source: (root.mode === "apps" && modelData && modelData.icon) ? "image://icon/" + modelData.icon : ""
                                    visible: root.mode === "apps" && source.toString() !== ""
                                }

                                // Clipboard Entry Placeholder Icon (Only visible in Clipboard mode)
                                Text {
                                    Layout.fillWidth: true
                                    text: root.mode === "apps" ? (modelData ? modelData.name : "") : modelData
                                    color: Theme.get.textColor
                                    font.family: "Inter, sans-serif"
                                    font.pixelSize: 14
                                    font.weight: ListView.isCurrentItem ? Font.DemiBold : Font.Normal
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight // Clean truncation for long clipboard entries
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: appListView.currentIndex = index
                                onClicked: executeSelection(index)
                            }
                        }
                    }
                }
            }
        }
    }
}
