import QtQuick
import QtQuick.Controls 2.5

Button {
    id: modeButton
    width: 90
    height: 80

    required property string iconPath
    property bool activated: false

    background: Rectangle {
        anchors.fill: parent
        color: "transparent"
    }

    contentItem: Rectangle {
        id: content
        anchors.fill: parent
        color: modeButton.hovered ? (modeButton.activated ? "#101010" : "#242424") : (modeButton.activated ? "#151515" : "transparent")
        radius: 20

        Text {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 12
            text: modeButton.text
            color: "#E8E7E0"
            font.pixelSize: 13
        }

        Image {
            anchors.top: parent.top
            anchors.topMargin: 12
            anchors.horizontalCenter: parent.horizontalCenter
            width: 30
            height: 30
            source: iconPath
            fillMode: Image.PreserveAspectFit
        }
    }
}
