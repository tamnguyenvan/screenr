import QtQuick
import QtQuick.Controls 2.5

Rectangle {
    id: customSelector
    width: 700
    height: 400
    visible: startupWindow.selectedMode == "custom"
    color: "transparent"

    readonly property int anchorSize: 24

    function resizeSelector(anchor, pressed, posX, posY) {
        if (pressed) {
            var deltaX = posX - anchor.startX
            var deltaY = posY - anchor.startY
            console.log('deltaX', deltaX)
            console.log('deltaY', deltaY)

            if (anchor.name == "topLeft") {
                var newWidth = width - deltaX
                var newHeight = height - deltaY
            }

            x = posX
            y = posY
            width = newWidth
            height = newHeight
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: parent.width - parent.anchorSize
        height: parent.height - parent.anchorSize
        border.width: 2
        border.color: "white"
        color: "transparent"
    }

    AnchorButton {
        id: topLeftButton
        width: parent.anchorSize
        height: parent.anchorSize
        anchors.top: parent.top
        anchors.left: parent.left
        name: "topLeft"
    }

    AnchorButton {
        id: topRightButton
        width: parent.anchorSize
        height: parent.anchorSize
        anchors.top: parent.top
        anchors.right: parent.right
        name: "topRight"
    }

    AnchorButton {
        id: bottomLeftButton
        width: parent.anchorSize
        height: parent.anchorSize
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        name: "bottomLeft"
    }

    AnchorButton {
        id: bottomButton
        width: parent.anchorSize
        height: parent.anchorSize
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        name: "bottomRight"
    }
}
