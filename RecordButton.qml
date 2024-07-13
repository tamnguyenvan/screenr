import QtQuick
import QtQuick.Controls 2.5

Button {
    id: recordButton
    width: 52
    height: 52

    background: Rectangle {
        anchors.centerIn: parent
        width: 36
        height: 36
        color: recordButton.hovered ? Qt.lighter("#C7162B", 1.06) : "#C7162B"
        radius: 20
    }

    contentItem: Image {
        anchors.fill: parent
        source: "/home/tamnv/Projects/exp/screenr/resources/icons/record.svg"
    }
}
