import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Settings

import "config.js" as Config

Scope {
    id: root

    // Track center state at root level
    property bool centerOpen: true

    // Model for storing notification history
    ListModel {
        id: history
    }

    NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: n => {
            history.insert(0, {
                summary: n.summary,
                body: n.body,
                appName: n.appName,
                urgency: n.urgency,
                time: Qt.formatDateTime(new Date(), "HH:mm")
            });
            n.tracked = true;
        }
    }

    IpcHandler {
        target: "notifications"
        function toggle(): void {
            root.centerOpen = !root.centerOpen;
        }
        function show(): void {
            root.centerOpen = true;
        }
        function hide(): void {
            root.centerOpen = false;
        }
    }

    // Notification center window
    PanelWindow {
        visible: root.centerOpen
        anchors {
            top: true
            left: true
        }
        margins {
            top: 40
            left: 12
        }
        implicitWidth: 380
        // Constrain the panel's maximum height dynamically to support scrolling elegantly
        implicitHeight: Math.min(500, centerCol.implicitHeight + 24)
        color: Theme.get.transparent
        exclusionMode: ExclusionMode.Ignore

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: Theme.get.bgColor
            border.width: 2
            border.color: Theme.get.infoColor

            ColumnLayout {
                id: centerCol
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                // Header Row
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: "Notifications"
                        font.family: Config.bar.fontFamily
                        font.pixelSize: Config.bar.fontSize + 2
                        font.bold: true
                        color: Theme.get.infoColor
                    }

                    Text {
                        text: "Clear All"
                        visible: history.count > 0
                        font.family: Config.bar.fontFamily
                        font.pixelSize: Config.bar.fontSize - 1
                        color: Theme.get.errorColor

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: history.clear()
                        }
                    }
                }

                // Placeholder message when history is empty
                Text {
                    text: "No notifications"
                    color: Theme.get.textColor
                    opacity: 0.5
                    font.family: Config.bar.fontFamily
                    font.pixelSize: Config.bar.fontSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 100
                    visible: history.count === 0
                }

                // Scrollable list of active notification history
                ListView {
                    id: historyListView
                    visible: history.count > 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 350 // Bounds height limit for scroll bar layout
                    clip: true
                    spacing: 8

                    model: history
                    delegate: Rectangle {
                        id: historyCard
                        width: ListView.view.width
                        height: historyCardLayout.implicitHeight + 16
                        color: Theme.get.fbColor
                        radius: 6

                        RowLayout {
                            id: historyCardLayout
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 10

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        Layout.fillWidth: true
                                        text: model.summary
                                        color: Theme.get.textColor
                                        font.family: Config.bar.fontFamily
                                        font.pixelSize: Config.bar.fontSize
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: model.time
                                        color: Theme.get.textColor
                                        opacity: 0.6
                                        font.family: Config.bar.fontFamily
                                        font.pixelSize: Config.bar.fontSize - 3
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    visible: text !== ""
                                    text: model.body
                                    color: Theme.get.textColor
                                    font.family: Config.bar.fontFamily
                                    font.pixelSize: Config.bar.fontSize - 1
                                    wrapMode: Text.WordWrap
                                }

                                Text {
                                    visible: model.appName !== ""
                                    text: model.appName
                                    color: Theme.get.infoColor
                                    font.family: Config.bar.fontFamily
                                    font.pixelSize: Config.bar.fontSize - 2
                                }
                            }

                            // Individual close / remove button
                            Text {
                                text: "✕"
                                color: Theme.get.errorColor
                                font.bold: true
                                Layout.alignment: Qt.AlignTop
                                font.pixelSize: Config.bar.fontSize

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: history.remove(index)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // popup notification window
    PanelWindow {
        anchors {
            top: true
            right: true
        }
        margins {
            top: 40
            right: 12
        }
        implicitWidth: 380
        implicitHeight: Math.max(1, column.implicitHeight)
        color: Theme.get.transparent
        exclusionMode: ExclusionMode.Ignore

        ColumnLayout {
            id: column
            width: parent.width
            spacing: 10

            Repeater {
                model: server.trackedNotifications
                delegate: Rectangle {
                    id: card
                    required property var modelData

                    Timer {
                        running: card.modelData.urgency !== NotificationUrgency.Critical
                        interval: Config.notifications.timeout
                        onTriggered: card.modelData.dismiss()
                    }

                    Layout.fillWidth: true
                    Layout.preferredHeight: layout.implicitHeight + 20
                    radius: 8
                    color: Theme.get.bgColor
                    border.width: 2
                    border.color: modelData.urgency === NotificationUrgency.Critical ? Theme.get.errorColor : Theme.get.infoColor

                    RowLayout {
                        id: layout
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Image {
                            Layout.preferredHeight: 36
                            Layout.preferredWidth: 36
                            Layout.alignment: Qt.AlignTop
                            fillMode: Image.PreserveAspectFit
                            visible: source.toString() !== ""
                            source: card.modelData.image || card.modelData.appIcon || ""
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: card.modelData.summary
                                color: Theme.get.textColor
                                font.family: Config.bar.fontFamily
                                font.pixelSize: Config.bar.fontSize
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: card.modelData.body
                                color: Theme.get.textColor
                                font.family: Config.bar.fontFamily
                                font.pixelSize: Config.bar.fontSize - 1
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: card.modelData.dismiss()
                    }
                }
            }
        }
    }
}
