import QtQuick 2.15

Item {
    id: area

    signal mouseEntered(real mouseX)
    signal mouseExited
    signal clicked(real clickX)

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            area.mouseEntered(mouseX)
        }

        onExited: {
            area.mouseExited()
        }

        onPositionChanged: {
            if (containsMouse) {
                area.mouseEntered(mouseX)
            }
        }

        onClicked: {
            area.clicked(mouseX)
        }
    }
}
