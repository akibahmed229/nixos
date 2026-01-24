// system imports
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Widgets

// custom imports
import qs.Settings

// Root container for the volume widget
Item {
    id: root
    // The visible layout for icons and text
    RowLayout {
        id: contentLayout
        spacing: 8
        // --- Speaker Volume Label ---
        Text {
            id: speakerLabel
            text: "---%"
            color: Theme.get.accentColor
            font.family: "Inter, sans-serif"
        }
    }
    // Size the component based on the content
    implicitWidth: contentLayout.implicitWidth
    implicitHeight: contentLayout.implicitHeight
    // --- Event Listeners for Real-time Updates ---
    // Listener for the default audio sink (speakers/headphones)
    Connections {
        target: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null

        function updateSpeakerVolume() {
            // Check that the target exists AND its volume property is a number
            if (target && typeof target.volume === 'number') {
                // Inline icon computation to ensure real-time update
                var currentIcon = target.muted ? "" : (target.volume === 0 ? "" : "");
                speakerLabel.text = currentIcon + "   " + Math.round(target.volume * 100) + "%";
            } else {
                speakerLabel.text = " ---%";
            }
        }
        function onVolumeChanged() {
            updateSpeakerVolume();
        }
        function onMutedChanged() {
            updateSpeakerVolume();
        }

        Component.onCompleted: updateSpeakerVolume() // Initial update
    }
    // --- Clickable Area to Launch pavucontrol ---
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            launcher.running = true;
        }
    }
    // Process to launch the volume control utility
    Process {
        id: launcher
        command: ["pwvucontrol"]
    }
}
