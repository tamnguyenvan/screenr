import QtQuick
import QtQuick.Controls 2.5
import QtQuick.Layouts

Button {
    id: anchorButton

    property int startX
    property int startY
    required property string name

    background: Rectangle {
        width: anchorButton.width
        height: anchorButton.height
        color: "white"
        radius: parent.width / 2
    }

    contentItem: Item {
        width: anchorButton.width
        height: anchorButton.height
    }

    MouseArea {
        id: anchorButtonMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.SizeBDiagCursor

        onPressed: {
            var pos = anchorButton.mapToItem(rootItem, mouseX, mouseY)
            startX = pos.x
            startY = pos.y
        }

        onPositionChanged: {
            var pos = anchorButtonMouseArea.mapToItem(rootItem, mouseX, mouseY)
            console.log('pos', pos.x, pos.y)
            customSelector.resizeSelector(anchorButton, pressed, pos.x, pos.y)
        }
    }
}
