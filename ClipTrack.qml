import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Rectangle {
    id: clipTrack
    implicitWidth: 100
    implicitHeight: 60
    radius: 10
    color: "#614BF9"

    signal positionChanged(real x)
    signal leftMouseClicked(real clickX)
    signal rightMouseClicked(real clickX)

    property int resizeHandleWidth: 10
    property bool resizing: false

    Rectangle {
        width: parent.width - 20
        height: parent.height
        x: 10
        y: 0
        color: "#4329F4"

        ColumnLayout {
            anchors.fill: parent
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: 4
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                Image {
                    source: "/home/tamnv/Projects/exp/screenr/resources/icons/cursor.svg"
                }
                Label {
                    text: qsTr("Zoom")
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 10

                RowLayout {
                    spacing: 4
                    Image {
                        source: "/home/tamnv/Projects/exp/screenr/resources/icons/zoom.svg"
                    }

                    Label {
                        text: qsTr("2x")
                    }
                }

                RowLayout {
                    spacing: 4
                    Image {
                        source: "/home/tamnv/Projects/exp/screenr/resources/icons/mouse.svg"
                    }

                    Label {
                        text: qsTr("Auto")
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        property int dragStartX: 0
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        drag {
            target: parent
            axis: Drag.XAxis
            smoothed: true
            minimumX: 0
        }

        onReleased: {
            zoomTrack.positionChanged(clipTrack.x)
        }

        onClicked: event => {
                       if (event.button === Qt.LeftButton) {
                           clipTrack.leftMouseClicked(mouseX)
                       }
                   }
    }

    MouseArea {
        id: leftResizeHandle
        width: resizeHandleWidth
        height: parent.height
        anchors.left: parent.left
        cursorShape: Qt.SizeHorCursor
        drag {
            target: parent
            axis: Drag.XAxis
        }
        onPressed: {
            resizing = true
        }
        onReleased: {
            resizing = false
            clipTrack.positionChanged(clipTrack.x)
            clipTrack.widthChanged(clipTrack.width)
        }
        onMouseXChanged: {
            if (drag.active) {
                var deltaX = mouseX
                clipTrack.x += deltaX
                clipTrack.width -= deltaX
                if (clipTrack.width < clipTrack.implicitWidth) {
                    clipTrack.width = clipTrack.implicitWidth
                    clipTrack.x = drag.maximumX
                }
            }
        }
    }

    MouseArea {
        id: rightResizeHandle
        width: resizeHandleWidth
        height: parent.height
        anchors.right: parent.right
        cursorShape: Qt.SizeHorCursor
        drag {
            target: parent
            axis: Drag.XAxis
        }
        onPressed: {
            resizing = true
        }
        onReleased: {
            resizing = false
            clipTrack.widthChanged(clipTrack.width)
        }
        onMouseXChanged: {
            if (drag.active) {
                var deltaX = mouseX
                clipTrack.width += deltaX
                if (clipTrack.width < clipTrack.implicitWidth) {
                    clipTrack.width = clipTrack.implicitWidth
                }
            }
        }
    }
}
