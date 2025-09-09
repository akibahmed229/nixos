// system import
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets

// custom import
import qs.Settings

Scope {
    id: root

    // Track the pipewire node so it's ready once available (optional/helpful)
    PwObjectTracker {
        id: pwTracker
        objects: [Pipewire.defaultAudioSink]
    }

    // last polled volume (null means unknown)
    property real lastVolume: -1.0

    // Whether to show the OSD
    property bool shouldShowOsd: false

    // Timer that hides the OSD after a short delay
    Timer {
        id: hideTimer
        interval: 1000
        repeat: false
        onTriggered: root.shouldShowOsd = false
    }

    // Poller: checks the sink's current volume periodically.
    Timer {
        id: pollTimer
        interval: 150   // 150ms is responsive without being too hot
        running: true
        repeat: true

        onTriggered: {
            // Safely read the volume (may be undefined)
            var volObj = Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio ? Pipewire.defaultAudioSink.audio : null;
            var v = volObj && typeof volObj.volume !== "undefined" ? volObj.volume : null;

            if (v === null) {
                // sink not available yet
                return;
            }

            // If value changed (accounting for small float jitter), show OSD
            if (root.lastVolume < 0 || Math.abs(v - root.lastVolume) > 0.0005) {
                root.lastVolume = v;
                root.shouldShowOsd = true;
                hideTimer.restart();
            }
        }
    }

    // Create/destroy the PanelWindow based on shouldShowOsd (LazyLoader keeps memory down)
    LazyLoader {
        active: root.shouldShowOsd

        PanelWindow {
            // Position near the bottom center of the current screen
            anchors.bottom: true
            margins.bottom: screen.height / 5
            exclusiveZone: 0

            implicitWidth: 400
            implicitHeight: 50
            color: "transparent"
            mask: Region {} // let clicks pass through

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: Theme.get.fbColor

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 10
                        rightMargin: 15
                    }

                    IconImage {
                        implicitSize: 40
                        source: Qt.resolvedUrl("volume.svg")
                    }

                    Rectangle {
                        // Stretches to fill all left-over space
                        Layout.fillWidth: true
                        implicitHeight: 10
                        radius: 20
                        color: Theme.get.bgColor

                        Rectangle {
                            id: filled
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }

                            // safe computation: clamp volume (0..1), fallback to 0
                            property real safeVol: Math.max(0, Math.min(1, Pipewire.defaultAudioSink?.audio?.volume ?? root.lastVolume ?? 0))
                            implicitWidth: parent.width * filled.safeVol
                            radius: parent.radius
                        }
                    }
                }
            }
        }
    }
}
