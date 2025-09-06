// ClockWidget.qml
import QtQuick

Text {
    // A property the creator of this type is required to set.
    // Note that we could just set `text` instead, but don't because your
    // clock probably will not be this simple.
    required property string time

    text: time
}
