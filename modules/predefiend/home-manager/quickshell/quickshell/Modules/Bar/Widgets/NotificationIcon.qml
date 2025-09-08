import QtQuick
import QtQuick.Controls
import qs.Modules.Notification

// This Row acts as a container for the button and its associated panel.
Row {
    id: root
    leftPadding: 10

    Item {

        // We set the size of this widget to be the same size as the button inside it.
        implicitWidth: notifToggle.implicitWidth
        implicitHeight: notifToggle.implicitHeight

        // The notification bell icon button
        Button {
            id: notifToggle
            icon.source: "Icons/bell-solid-full.svg"
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
}
