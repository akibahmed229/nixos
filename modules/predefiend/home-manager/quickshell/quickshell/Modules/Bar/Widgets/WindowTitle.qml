import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

Rectangle {
    Layout.fillHeight: true
    color: "transparent"
    Layout.fillWidth: true
    Layout.maximumWidth: 300

    // Ensure toplevels are refreshed on startup (Hyprland data might not be loaded initially)
    Component.onCompleted: {
        Hyprland.refreshToplevels();
    }

    property string activeWindowTitle: {
        // Directly use Hyprland.activeToplevel for the currently active window
        const activeToplevel = Hyprland.activeToplevel;
        if (activeToplevel && activeToplevel.title) {
            const title = activeToplevel.title;
            // console.log("DEBUG qml: Found active toplevel title:", title);  // Temporary debug; remove after testing
            return title;
        }

        // console.log("DEBUG qml: No active toplevel or title available");
        return "";
    }

    Text {
        id: windowTitle
        anchors.centerIn: parent
        text: parent.activeWindowTitle
        color: "#8ec07c"
        font.pixelSize: parent.height * 0.0
        elide: Text.ElideMiddle
        width: parent.width
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            // console.log("Raw event:", event.event, "Name:", event.name);
            // Trigger refresh and recompute on relevant events
            if (["windowtitle", "windowtitlev2", "activewindow", "activewindowv2", "focusedmon", "openwindow", "closewindow"].includes(event.name)) {
                Hyprland.refreshToplevels();  // Ensure latest data
                const title = activeWindowTitle;  // Forces property recompute
                // console.log("Window event:", event.name, "Title:", title);
            }
        }
    }
}
