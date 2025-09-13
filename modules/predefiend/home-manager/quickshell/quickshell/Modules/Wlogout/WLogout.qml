// system import
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// custom import
import qs.Settings
import qs.Modules.Wlogout

Variants {
    model: Quickshell.screens

    property color backgroundColor: Theme.get.bgColor
    property color buttonColor: Theme.get.buttonBackground
    property color buttonHoverColor: Theme.get.buttonHover
    default property list<LogoutButton> buttons

    PanelWindow {
        property var modelData

        visible: Controller.isOpen  // Bind directly to singleton's isOpen
        screen: modelData
        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        color: "transparent"

        contentItem {
            focus: true
            Keys.onPressed: event => {
                if (event.key == Qt.Key_Escape)
                    Controller.isOpen = false;
                else {
                    for (let i = 0; i < buttons.length; i++) {
                        let button = buttons[i];
                        if (event.key == button.keybind)
                            button.exec();
                    }
                }
            }
        }

        anchors {
            top: true
            left: true
            bottom: true
            right: true
        }

        Rectangle {
            color: backgroundColor
            anchors.fill: parent

            MouseArea {
                anchors.fill: parent
                onClicked: Controller.isOpen = false // Hide on background click

                GridLayout {
                    anchors.centerIn: parent
                    width: parent.width * 0.75
                    height: parent.height * 0.75
                    columns: 3
                    columnSpacing: 0
                    rowSpacing: 0

                    Repeater {
                        model: buttons
                        delegate: Rectangle {
                            required property LogoutButton modelData
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: ma.containsMouse ? buttonHoverColor : buttonColor
                            border.color: "black"
                            border.width: ma.containsMouse ? 0 : 1

                            MouseArea {
                                id: ma
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: modelData.exec()
                            }
                            Image {
                                id: icon
                                anchors.centerIn: parent
                                source: `icons/${modelData.icon || "default"}.png` // Fallback to "default" icon if null
                                width: parent.width * 0.25
                                height: parent.width * 0.25
                            }
                            Text {
                                anchors {
                                    top: icon.bottom
                                    topMargin: 20
                                    horizontalCenter: parent.horizontalCenter
                                }
                                text: modelData.text
                                font.pointSize: 20
                                color: "white"
                            }
                        }
                    }
                }
            }
        }
    }
}
