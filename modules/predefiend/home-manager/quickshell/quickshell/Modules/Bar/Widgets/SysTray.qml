import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import QtQuick.Controls  // For ToolTip

Repeater {
    model: SystemTray.items

    delegate: Item {
        implicitWidth: 18
        implicitHeight: 18

        Image {
            anchors.fill: parent
            width: 16
            height: 16
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
                return icon;
            }
            fillMode: Image.PreserveAspectFit
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onClicked: function (mouse) {
                if (mouse.button === Qt.LeftButton) {
                    modelData.activate(mouse.x, mouse.y);
                } else if (mouse.button === Qt.MiddleButton) {
                    modelData.secondaryActivate(mouse.x, mouse.y);
                }
            }
            onPressed: function (mouse) {
                if (mouse.button === Qt.RightButton) {
                    modelData.open(mouse.x, mouse.y);
                }
            }
        }
    }
}
