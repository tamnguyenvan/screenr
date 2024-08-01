// RecordButton.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Button {
    id: recordButton
    implicitWidth: 60
    implicitHeight: 60
    Layout.alignment: Qt.AlignCenter

    background: Item {
        anchors.fill: parent
        Rectangle {
            id: outerCircle
            anchors.centerIn: parent
            width: 60
            height: 60
            radius: width / 2
            color: "transparent"
            border.color: "white"
            border.width: 5
        }
        Rectangle {
            id: innerCircle
            anchors.centerIn: parent
            width: 40
            height: 40
            radius: width / 2
            color: recordButton.hovered ? Qt.lighter("red", 1.3) : "red"
            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }
        }
    }
}
