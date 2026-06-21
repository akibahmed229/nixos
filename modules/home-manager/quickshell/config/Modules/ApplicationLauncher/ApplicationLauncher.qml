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

    // Logic to fetch system apps and fuzzy match the search text
    property var filteredApps: {
        const query = searchInput.text.toLowerCase().trim();
        // DesktopEntries.applications collects all valid system desktop entries
        const allApps = Array.from(DesktopEntries.applications.values);

        if (query === "") {
            return allApps.filter(app => !app.noDisplay);
        }

        return allApps.filter(app => {
            if (app.noDisplay)
                return false;
            const name = (app.name || "").toLowerCase();
            const comment = (app.comment || "").toLowerCase();
            return name.includes(query) || comment.includes(query);
        });

        // Always reset selection index back to the top item on typing
        appListView.currentIndex = 0;
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            launcherOpen = !launcherOpen;
        }
        function show(): void {
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
                                text: "☰"
                                font.pixelSize: 26
                                color: Theme.get.whiteColor
                            }

                            TextField {
                                id: searchInput
                                Layout.fillWidth: true
                                placeholderText: "Search applications..."
                                placeholderTextColor: Theme.get.textColor
                                color: Theme.get.textColor
                                background: null
                                font.family: "Inter, sans-serif"
                                font.pixelSize: 15
                                selectByMouse: true

                                // Route keyboard navigation keys downwards directly into the list view navigation handler
                                Keys.onPressed: event => {
                                    if (event.key === Qt.Key_Down) {
                                        if (appListView.currentIndex < appListView.count - 1) {
                                            appListView.currentIndex++;
                                        }
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Up) {
                                        if (appListView.currentIndex > 0) {
                                            appListView.currentIndex--;
                                        }
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Return) {
                                        var app = root.filteredApps[appListView.currentIndex];
                                        console.log(app);
                                        if (app) {
                                            app.execute();
                                            root.launcherOpen = false;
                                            searchInput.text = "";
                                        }
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Tab) {
                                        appListView.currentIndex++;
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Backtab) {
                                        appListView.currentIndex--;
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Escape) {
                                        launcherOpen = false;
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

                    // Applications View List
                    ListView {
                        id: appListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 4
                        model: filteredApps

                        delegate: Rectangle {
                            id: delegateItem
                            width: ListView.view.width
                            height: 48
                            radius: 6
                            // Highlighting currently selected element
                            color: ListView.isCurrentItem ? Theme.get.altBgColor : "transparent"
                            border.color: ListView.isCurrentItem ? Theme.get.infoColor : "transparent"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 12

                                // Application Icon fallback or placeholder
                                Image {
                                    Layout.preferredWidth: 26
                                    Layout.preferredHeight: 26
                                    source: modelData.icon ? "image://icon/" + modelData.icon : ""
                                    visible: source.toString() !== ""
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.name
                                    color: Theme.get.textColor
                                    font.family: "Inter, sans-serif"
                                    font.pixelSize: 14
                                    font.weight: ListView.isCurrentItem ? Font.DemiBold : Font.Normal
                                    font.pointSize: 12
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: appListView.currentIndex = index
                                // Executes the application when clicked
                                onClicked: {
                                    modelData.execute();
                                    launcherOpen = false;
                                    searchField.text = "";
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
