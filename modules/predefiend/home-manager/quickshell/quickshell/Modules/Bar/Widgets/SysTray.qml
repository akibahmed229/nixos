import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.Utils

RowLayout {
    spacing: 5

    Repeater {
        model: SystemTray.items.values

        MouseArea {
            id: delegate
            required property SystemTrayItem modelData
            property alias item: delegate.modelData

            Layout.fillHeight: true
            implicitWidth: icon.implicitWidth + 5

            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            hoverEnabled: true

            onClicked: event => {
                if (event.button == Qt.LeftButton) {
                    item.activate();
                } else if (event.button == Qt.MiddleButton) {
                    item.secondaryActivate();
                } else if (event.button == Qt.RightButton) {
                    menuAnchor.open();
                }
            }

            onWheel: event => {
                event.accepted = true;
                const points = event.angleDelta.y / 120;
                item.scroll(points, false);
            }

            IconImage {
                id: icon
                anchors.centerIn: parent
                source: {
                    let icon = modelData?.icon || "";
                    if (!icon)
                        return "";
                    // Process icon path
                    if (icon.includes("?path=")) {
                        const [name, path] = icon.split("?path=");
                        const fileName = name.substring(name.lastIndexOf("/") + 1);
                        return `file://${path}/${fileName}`;
                    }
                    // For named icons like "drive-removable-media-usb-pendrive", return as-is for theme resolution
                    // Fallback: If it's a known USB/media icon, use a generic one (adjust as needed)
                    if (icon === "image://icon/drive-removable-media-usb-pendrive") {
                        return Qt.resolvedUrl("Icons/usb-drive.png");
                    }
                    return icon;
                }
                implicitSize: 16
                // Optional: Add error handling for failed loads
                onStatusChanged: if (status === Image.Error) {
                    source = Qt.resolvedUrl("Icons/warning.png");  // Generic warning icon as ultimate fallback
                }
            }

            QsMenuAnchor {
                id: menuAnchor
                menu: item.menu

                anchor.window: delegate.QsWindow.window
                anchor.adjustment: PopupAdjustment.Flip

                anchor.onAnchoring: {
                    const window = delegate.QsWindow.window;
                    const widgetRect = window.contentItem.mapFromItem(delegate, 0, delegate.height, delegate.width, delegate.height);

                    menuAnchor.anchor.rect = widgetRect;
                }
            }

            Tooltip {
                relativeItem: delegate.containsMouse ? delegate : null

                Label {
                    text: delegate.item.tooltipTitle || delegate.item.id
                }
            }
        }
    }
}
