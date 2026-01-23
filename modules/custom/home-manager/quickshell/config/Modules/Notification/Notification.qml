// system import
import QtQuick
import QtQuick.Layouts

Text {
    required property int id
    required property string body
    required property string summary
    property int margin

    text: `- ${summary}: ${body}`
    width: parent.width
    wrapMode: Text.WordWrap
    Layout.fillWidth: true
}
