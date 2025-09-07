import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell.Wayland

Item {
    id: root
    required property LockContext context

    // Background wallpaper
    Image {
        anchors.fill: parent
        source: "/home/akib/.cache/swww/Wallpaper"  // must be absolute path
        fillMode: Image.PreserveAspectCrop
    }

    // A dark overlay to make text readable
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.35
    }

    // Existing content (clock, password field, etc.)
    Label {
        id: clock
        property var date: new Date()

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 100
        }

        renderType: Text.NativeRendering
        font.pointSize: 80
        color: "white"

        Timer {
            running: true
            repeat: true
            interval: 1000
            onTriggered: clock.date = new Date()
        }

        text: {
            const hours = this.date.getHours().toString().padStart(2, '0');
            const minutes = this.date.getMinutes().toString().padStart(2, '0');
            return `${hours}:${minutes}`;
        }
    }

    ColumnLayout {
        visible: Window.active

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.verticalCenter
        }

        RowLayout {
            TextField {
                id: passwordBox

                implicitWidth: 400
                padding: 10
                focus: true
                enabled: !root.context.unlockInProgress
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhSensitiveData
                onTextChanged: root.context.currentText = this.text
                onAccepted: root.context.tryUnlock()

                // colors
                color: "#ebdbb2"                   // text color
                placeholderText: "Enter password"
                placeholderTextColor: "#928374"
                background: Rectangle {
                    implicitHeight: 40
                    radius: 6
                    color: "#3c3836"               // bg0_hard
                    border.color: passwordBox.activeFocus ? "#83a598" : "#665c54"
                    border.width: 2
                }

                Connections {
                    target: root.context
                    function onCurrentTextChanged() {
                        passwordBox.text = root.context.currentText;
                    }
                }
            }

            Button {
                text: "Unlock"
                padding: 10
                background: Rectangle {
                    radius: 6
                    color: enabled ? "#458588" : "#504945"   // Gruvbox blue / gray
                }
                focusPolicy: Qt.NoFocus
                enabled: !root.context.unlockInProgress && root.context.currentText !== ""
                onClicked: root.context.tryUnlock()
            }
        }

        Label {
            visible: root.context.showFailure
            text: "Incorrect password"
            color: "red"
        }
    }
}
