import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: hoverZoomTrack
    color: "blue"
    radius: 10
    visible: false
    opacity: 0.5

    RowLayout {
        anchors.fill: parent
        Layout.alignment: Qt.AlignCenter
        Image {
            source: "/home/tamnv/Projects/exp/screenr/resources/icons/add.svg"
        }
    }
}
