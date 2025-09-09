// system imports
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Hyprland    // Hyprland integration

// custom imports
import qs.Settings            // theme colors
import qs.Utils.Tooltip

// Using a simple Item as the root. It will not try to control its own size in the layout.
Item {
    id: root

    // --- Layout Properties ---
    Layout.fillHeight: true
    // Explicitly tell the parent layout what our desired width is.
    Layout.preferredWidth: windowTitle.implicitWidth
    // The parent layout will respect this, but still cap it at maximumWidth.
    Layout.maximumWidth: 300
    clip: true // Ensure text doesn't render outside the final calculated bounds.

    // --- Ensure Hyprland data is initialized ---
    Component.onCompleted: Hyprland.refreshToplevels()

    // --- Computed property: get current active window title ---
    property string activeWindowTitle: {
        const activeToplevel = Hyprland.activeToplevel;
        return activeToplevel && activeToplevel.title ? activeToplevel.title : "Desktop";
    }

    // --- Display window title ---
    Text {
        id: windowTitle
        // Anchor it to the parent Item. The parent's size will be determined by the layout in Bar.qml.
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        text: parent.activeWindowTitle
        color: Theme.get.infoColor
        font.pixelSize: 14

        // Elide will now work correctly because the parent 'root' item gets a definitive width.
        elide: Text.ElideMiddle
    }

    // --- MouseArea for Tooltip ---
    MouseArea {
        id: delegate
        anchors.fill: parent
        hoverEnabled: true

        Tooltip {
            relativeItem: {
                return delegate.containsMouse ? delegate : null;
            }
            Label {
                text: activeWindowTitle
                color: Theme.get.textColor
            }
        }
    }

    // --- React to Hyprland events ---
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (["windowtitle", "windowtitlev2", "activewindow", "activewindowv2", "focusedmon", "openwindow", "closewindow"].includes(event.name)) {
                Hyprland.refreshToplevels();
            }
        }
    }
}
