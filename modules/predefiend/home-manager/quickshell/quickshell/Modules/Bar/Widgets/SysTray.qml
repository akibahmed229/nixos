// system imports
import QtQuick
import Quickshell
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.SystemTray

// custom imports
import qs.Utils.Tooltip   // shared tooltip helper
import qs.Settings        // theme colors

// Layout container for all tray icons
RowLayout {
    spacing: 5

    // Create a tray item for each system tray entry
    Repeater {
        model: SystemTray.items.values

        // Each tray icon is clickable/interactive
        MouseArea {
            id: delegate
            required property SystemTrayItem modelData
            property alias item: delegate.modelData

            Layout.fillHeight: true
            implicitWidth: icon.implicitWidth + 5

            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            hoverEnabled: true

            // Handle mouse clicks on tray icons
            onClicked: event => {
                if (event.button == Qt.LeftButton) {
                    item.activate();            // primary action
                } else if (event.button == Qt.MiddleButton) {
                    item.secondaryActivate();   // secondary action
                } else if (event.button == Qt.RightButton) {
                    menuAnchor.open();          // open context menu
                }
            }

            // Forward scroll events to the tray item (e.g. volume)
            onWheel: event => {
                event.accepted = true;
                const points = event.angleDelta.y / 120;
                item.scroll(points, false);
            }

            // --- Tray icon image ---
            IconImage {
                id: icon
                implicitSize: 16
                anchors.centerIn: parent

                // Resolve correct icon source (system, custom, or fallback)
                source: {
                    let icon = modelData?.icon || "";
                    if (!icon)
                        return "";
                    if (icon.includes("?path=")) {
                        // custom icon path (e.g. from app)
                        const [name, path] = icon.split("?path=");
                        const fileName = name.substring(name.lastIndexOf("/") + 1);
                        return `file://${path}/${fileName}`;
                    }
                    // Special case: USB icon → fallback image
                    if (icon === "image://icon/drive-removable-media-usb-pendrive") {
                        return Qt.resolvedUrl("Icons/usb-drive.png");
                    }
                    // Default: let theme resolve the icon
                    return icon;
                }

                // Fallback warning icon if load fails
                onStatusChanged: if (status === Image.Error) {
                    source = Qt.resolvedUrl("Icons/warning.png");
                }
            }

            // --- Right-click context menu anchor ---
            QsMenuAnchor {
                id: menuAnchor
                menu: item.menu
                anchor.window: delegate.QsWindow.window
                anchor.adjustment: PopupAdjustment.Flip

                // Position menu relative to the tray icon
                anchor.onAnchoring: {
                    const window = delegate.QsWindow.window;
                    const widgetRect = window.contentItem.mapFromItem(delegate, 0, delegate.height, delegate.width, delegate.height);
                    menuAnchor.anchor.rect = widgetRect;
                }
            }

            // --- Tooltip on hover ---
            Tooltip {
                relativeItem: delegate.containsMouse ? delegate : null
                Label {
                    text: delegate.item.tooltipTitle || delegate.item.id
                    color: Theme.get.textColor
                }
            }
        }
    }
}
