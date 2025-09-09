// system import
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// custom import
import qs.Modules.Notification

// This Row acts as a container for the button and its associated panel.
RowLayout {
    id: root
    Layout.leftMargin: 10

    Item {
        // We set the size of this widget to be the same size as the button inside it.
        implicitWidth: notifToggle.implicitWidth
        implicitHeight: notifToggle.implicitHeight

        // The notification bell icon button
        Button {
            id: notifToggle
            icon.source: "Icons/notification-bell.svg"
            background: null
            font.pixelSize: 22

            // When clicked, toggle the visibility of the notification panel.
            onClicked: {
                notifPanel.visible = !notifPanel.visible;
            }
        }

        // The notification panel that appears when the icon is clicked
        NotificationPanel {
            id: notifPanel
        }
    }
}
