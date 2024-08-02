import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Rectangle {
    id: clipTrack
    implicitWidth: 100
    implicitHeight: 60
    radius: 10
    color: "#B37606"

    signal positionChanged(real x)
    signal leftMouseClicked(real clickX)

    // signal rightMouseClicked(real clickX)
    property int resizeHandleWidth: 10
    property bool resizing: false
    property real videoLen: 0

    Rectangle {
        width: parent.width - 20
        height: parent.height
        x: 10
        y: 0
        color: "#865A0E"

        ColumnLayout {
            anchors.fill: parent
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: 4
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                Image {
                    source: "qrc:/resources/icons/clip.svg"
                }
                Label {
                    text: qsTr("Clip")
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 10

                RowLayout {
                    Image {
                        source: "qrc:/resources/icons/zoom.svg"
                    }

                    Label {
                        text: videoLen.toFixed(1) + "s"
                    }

                    Image {
                        source: "qrc:/resources/icons/clock.svg"
                    }

                    Label {
                        text: qsTr("1x")
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        // property int dragStartX: 0
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        // drag {
        //     target: parent
        //     axis: Drag.XAxis
        //     smoothed: true
        //     minimumX: 0
        // }
        onReleased: {
            clipTrack.positionChanged(clipTrack.x)
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
