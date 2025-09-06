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
            source: modelData.icon
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
                    modelData.contextMenu(mouse.x, mouse.y);
                }
            }
        }
    }
}
