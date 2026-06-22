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
    property string mode: "apps" // "apps", "clipboard", or "wallpaper"

    // Data storage arrays
    property var rawClipboard: []
    property var rawWallpapers: []

    // Unified logic to fetch list data and filter based on search input
    property var filteredItems: {
        const query = searchInput.text.toLowerCase().trim();

        if (root.mode === "apps") {
            const allApps = Array.from(DesktopEntries.applications.values);
            const visibleApps = allApps.filter(app => !app.noDisplay).sort((a, b) => (a.name || "").localeCompare(b.name || ""));
            if (query === "") {
                return visibleApps;
            }
            return visibleApps.filter(app => {
                const name = (app.name || "").toLowerCase();
                const comment = (app.comment || "").toLowerCase();
                return name.includes(query) || comment.includes(query);
            });
        } else if (root.mode === "clipboard") {
            if (query === "") {
                return root.rawClipboard;
            }
            return root.rawClipboard.filter(item => item.toLowerCase().includes(query));
        } else if (root.mode === "wallpaper") {
            if (query === "") {
                return root.rawWallpapers;
            }
            return root.rawWallpapers.filter(item => item.name.toLowerCase().includes(query));
        }
        return [];
    }

    // --- Processes ---

    // Process to query cliphist
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

    // Process to scan wallpapers
    Process {
        id: wallpaperScanner
        // Looks in $WALLPAPER env var, falls back to ~/Pictures if unset
        command: ["bash", "-c", "find \"${WALLPAPER:-$HOME/Pictures}\" -type f \\( -iname \\*.jpg -o -iname \\*.png -o -iname \\*.jpeg -o -iname \\*.webp -o -iname \\*.gif \\)"]
        stdout: StdioCollector {
            onStreamFinished: {
                var trimmed = text.trim();
                if (trimmed === "") {
                    root.rawWallpapers = [];
                    return;
                }
                var lines = trimmed.split("\n");
                var wpList = [];
                for (var i = 0; i < lines.length; i++) {
                    var path = lines[i].trim();
                    var name = path.substring(path.lastIndexOf('/') + 1);
                    wpList.push({
                        name: name,
                        path: path
                    });
                }
                root.rawWallpapers = wpList.sort((a, b) => a.name.localeCompare(b.name));
            }
        }
    }

    // Execution Processes
    Process {
        id: cliphistDecoder
    }
    Process {
        id: wallpaperSetter
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
        } else if (root.mode === "clipboard") {
            // Decode and write back to clipboard safely
            cliphistDecoder.command = ["bash", "-c", "cliphist decode <<< \"$1\" | wl-copy", "--", item];
            cliphistDecoder.running = true;
        } else if (root.mode === "wallpaper") {
            // Copy to cache and set via awww safely
            wallpaperSetter.command = ["bash", "-c", "mkdir -p ~/.cache/swww && cp \"$1\" ~/.cache/swww/Wallpaper && awww img \"$1\" --transition-step 2 --transition-fps 75 --transition-type right", "--", item.path];
            wallpaperSetter.running = true;
        }

        root.launcherOpen = false;
        searchInput.text = "";
    }

    // --- IPC Communication ---

    IpcHandler {
        target: "launcher"

        // App Launcher Mode
        function toggle(): void {
            root.mode = "apps";
            root.launcherOpen = !root.launcherOpen;
        }
        function show(): void {
            root.mode = "apps";
            root.launcherOpen = true;
        }

        // Clipboard Manager Mode
        function toggleClipboard(): void {
            root.mode = "clipboard";
            root.launcherOpen = !root.launcherOpen;
        }
        function showClipboard(): void {
            root.mode = "clipboard";
            root.launcherOpen = true;
        }

        // Wallpaper Picker Mode
        function toggleWallpaper(): void {
            root.mode = "wallpaper";
            root.launcherOpen = !root.launcherOpen;
        }
        function showWallpaper(): void {
            root.mode = "wallpaper";
            root.launcherOpen = true;
        }

        function hide(): void {
            root.launcherOpen = false;
        }
    }

    // --- UI Layout ---

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

        onVisibleChanged: {
            if (visible) {
                searchInput.text = "";
                searchInput.forceActiveFocus();
                appListView.currentIndex = 0;
                wallpaperGridView.currentIndex = 0;

                // Trigger specific background scanners based on selected mode
                if (root.mode === "clipboard") {
                    cliphistScanner.running = true;
                } else if (root.mode === "wallpaper") {
                    wallpaperScanner.running = true;
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "#80000000"

            MouseArea {
                anchors.fill: parent
                onClicked: root.launcherOpen = false
            }

            Rectangle {
                width: 600
                height: 580
                anchors.centerIn: parent
                color: Theme.get.bgColor
                border.color: Theme.get.infoColor
                border.width: 2
                radius: 12

                MouseArea {
                    anchors.fill: parent
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 14

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
                                text: root.mode === "apps" ? "☰" : (root.mode === "clipboard" ? "📋" : "🖼️")
                                font.pixelSize: 22
                                color: Theme.get.whiteColor
                            }

                            TextField {
                                id: searchInput
                                Layout.fillWidth: true
                                placeholderText: root.mode === "apps" ? "Search applications..." : (root.mode === "clipboard" ? "Search clipboard history..." : "Search wallpapers...")
                                placeholderTextColor: Theme.get.textColor
                                color: Theme.get.textColor
                                background: null
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 15
                                selectByMouse: true

                                onTextChanged: {
                                    appListView.currentIndex = 0;
                                    wallpaperGridView.currentIndex = 0;
                                }

                                Keys.onPressed: event => {
                                    // Dynamically route commands to the active view component
                                    var targetView = root.mode === "wallpaper" ? wallpaperGridView : appListView;
                                    // Math to calculate columns for the GridView (1 column for ListView)
                                    var cols = root.mode === "wallpaper" ? Math.max(1, Math.floor(targetView.width / targetView.cellWidth)) : 1;

                                    if (event.key === Qt.Key_Down) {
                                        if (targetView.currentIndex + cols < targetView.count) {
                                            targetView.currentIndex += cols;
                                        } else {
                                            targetView.currentIndex = targetView.count - 1; // Jump to end
                                        }
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Up) {
                                        if (targetView.currentIndex - cols >= 0) {
                                            targetView.currentIndex -= cols;
                                        } else {
                                            targetView.currentIndex = 0; // Jump to start
                                        }
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Tab) {
                                        if (targetView.currentIndex < targetView.count - 1) {
                                            targetView.currentIndex++;
                                        } else {
                                            targetView.currentIndex = 0;
                                        }
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Backtab) {
                                        if (targetView.currentIndex > 0) {
                                            targetView.currentIndex--;
                                        } else {
                                            targetView.currentIndex = targetView.count - 1;
                                        }
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Return) {
                                        executeSelection(targetView.currentIndex);
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Escape) {
                                        root.launcherOpen = false;
                                        event.accepted = true;
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Theme.get.buttonBorder
                        opacity: 0.3
                    }

                    // 1. Applications & Clipboard View List (Vertical)
                    ListView {
                        id: appListView
                        visible: root.mode !== "wallpaper"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 4
                        model: root.mode !== "wallpaper" ? root.filteredItems : []

                        delegate: Rectangle {
                            id: listDelegateItem
                            width: ListView.view.width
                            height: 48
                            radius: 6
                            color: ListView.isCurrentItem ? Theme.get.buttonHover : "transparent"
                            border.color: ListView.isCurrentItem ? Theme.get.infoColor : "transparent"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 12

                                // Application Icon
                                Image {
                                    Layout.preferredWidth: 26
                                    Layout.preferredHeight: 26
                                    source: (root.mode === "apps" && modelData && modelData.icon) ? "image://icon/" + modelData.icon : ""
                                    visible: root.mode === "apps" && source.toString() !== ""
                                }

                                // Clipboard Entry Placeholder Icon
                                Text {
                                    Layout.fillWidth: true
                                    text: root.mode === "apps" ? (modelData ? modelData.name : "") : modelData
                                    color: Theme.get.textColor
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 14
                                    font.weight: ListView.isCurrentItem ? Font.DemiBold : Font.Normal
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
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

                    // 2. Wallpapers Grid View
                    GridView {
                        id: wallpaperGridView
                        visible: root.mode === "wallpaper"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        cellWidth: 140
                        cellHeight: 160
                        model: root.mode === "wallpaper" ? root.filteredItems : []

                        delegate: Rectangle {
                            id: gridDelegateItem
                            width: wallpaperGridView.cellWidth - 10
                            height: wallpaperGridView.cellHeight - 10
                            radius: 8
                            color: GridView.isCurrentItem ? Theme.get.buttonHover : "transparent"
                            border.color: GridView.isCurrentItem ? Theme.get.infoColor : "transparent"
                            border.width: GridView.isCurrentItem ? 2 : 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 6

                                // Rounded image clipping wrapper for clean edges
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    color: "transparent"
                                    radius: 6
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        source: "file://" + modelData.path
                                        fillMode: Image.PreserveAspectCrop
                                        // Optimize memory usage by caching downscaled thumbnails
                                        sourceSize.width: 300
                                        sourceSize.height: 300
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.name
                                    color: Theme.get.textColor
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 12
                                    font.weight: GridView.isCurrentItem ? Font.DemiBold : Font.Normal
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: wallpaperGridView.currentIndex = index
                                onClicked: executeSelection(index)
                            }
                        }
                    }
                }
            }
        }
    }
}
