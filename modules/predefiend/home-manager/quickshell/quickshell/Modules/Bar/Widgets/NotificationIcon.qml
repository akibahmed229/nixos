import QtQuick
import QtQuick.Controls as QQC
import qs.Modules.Notification

// This Item acts as a container for the button and its associated panel.
Item {
    id: root

    // We set the size of this widget to be the same size as the button inside it.
    implicitWidth: notifToggle.implicitWidth
    implicitHeight: notifToggle.implicitHeight

    // The notification bell icon button
    QQC.Button {
        id: notifToggle
        text: "🔔"
        background: null
        font.pixelSize: 16

        // When clicked, toggle the visibility of the notification panel.
        onClicked: {
            notifPanel.visible = !notifPanel.visible;
        }
    }

    // The notification panel that appears when the icon is clicked
    NotificationPanel {
        id: notifPanel
        visible: false // Start hidden by default
        text_color: "white"
    }
}
