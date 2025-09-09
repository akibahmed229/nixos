// system imports
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland   // Hyprland integration

// custom imports
import qs.Settings           // theme colors

// Container for active window title
Rectangle {
    color: "transparent"
    Layout.fillHeight: true
    Layout.fillWidth: true
    Layout.maximumWidth: 300   // prevent overly long titles

    // --- Ensure Hyprland data is initialized ---
    Component.onCompleted: Hyprland.refreshToplevels()

    // --- Computed property: get current active window title ---
    property string activeWindowTitle: {
        const activeToplevel = Hyprland.activeToplevel;
        return activeToplevel && activeToplevel.title ? activeToplevel.title : "";
    }

    // --- Display window title ---
    Text {
        id: windowTitle
        anchors.centerIn: parent
        text: parent.activeWindowTitle
        color: Theme.get.infoColor
        font.pixelSize: parent.height * 0.0   // FIXME: currently 0 (invisible)
        elide: Text.ElideMiddle               // truncate long titles in the middle
        width: parent.width
    }

    // --- React to Hyprland events ---
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            // Refresh on window focus/title change
            if (["windowtitle", "windowtitlev2", "activewindow", "activewindowv2", "focusedmon", "openwindow", "closewindow"].includes(event.name)) {
                Hyprland.refreshToplevels();
                const title = activeWindowTitle; // recompute
            }
        }
    }
}
