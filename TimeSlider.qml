import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: timeSlider
    width: 20
    height: 220

    property string color: "#4329F3"
    property int pixelsPerSecond: 200

    Rectangle {
        id: timeSliderHead
        width: parent.width
        height: parent.width
        radius: parent.width / 2

        color: parent.color

        MouseArea {
            anchors.fill: parent

            drag {
                target: timeSlider
                axis: Drag.XAxis
                smoothed: true
                minimumX: 0
            }

            onReleased: {
                var currentFrame = Math.round(
                            timeSlider.x / root.pixelsPerFrame)
                videoController.jump_to_frame(currentFrame)
            }
        }
    }

    Rectangle {
        id: timeSliderBody
        width: 3
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        color: parent.color
    }
}
