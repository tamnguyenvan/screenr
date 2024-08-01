import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Rectangle {
    id: zoomTrack
    implicitWidth: 100
    implicitHeight: 60
    radius: 10
    color: "#614BF9"

    signal positionOrSizeChanged(real x, real width)
    signal leftMouseClicked(real clickX)
    signal rightMouseClicked(real clickX)

    property int resizeHandleWidth: 10
    property bool resizing: false
    readonly property int minWidth: 100

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
                    source: "qrc:/resources/icons/cursor.svg"
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
                        source: "qrc:/resources/icons/zoom.svg"
                    }

                    Label {
                        text: qsTr("2x")
                    }
                }

                RowLayout {
                    spacing: 4
                    Image {
                        source: "qrc:/resources/icons/mouse.svg"
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
            zoomTrack.positionOrSizeChanged(zoomTrack.x, zoomTrack.width)
        }

        onClicked: event => {
                       if (event.button === Qt.LeftButton) {
                           zoomTrack.leftMouseClicked(mouseX)
                       } else if (event.button === Qt.RightButton) {
                           contextMenu.popup()
                           zoomTrack.rightMouseClicked(mouseX)
                       }
                   }
    }

    Item {
        width: resizeHandleWidth
        height: parent.height
        anchors.left: parent.left

        MouseArea {
            id: leftResizeHandle
            anchors.fill: parent
            cursorShape: Qt.SizeHorCursor

            drag {
                target: parent
                axis: Drag.XAxis
            }

            onReleased: {
                zoomTrack.positionOrSizeChanged(zoomTrack.x, zoomTrack.width)
            }

            onMouseXChanged: {
                if (drag.active) {
                    zoomTrack.width = zoomTrack.width - mouseX
                    zoomTrack.x = zoomTrack.x + mouseX
                    if (zoomTrack.width < zoomTrack.minWidth) {
                        zoomTrack.width = zoomTrack.minWidth
                    }
                }
            }
        }
    }

    Item {
        width: resizeHandleWidth
        height: parent.height
        anchors.right: parent.right

        MouseArea {
            id: rightResizeHandle
            anchors.fill: parent
            cursorShape: Qt.SizeHorCursor

            drag {
                target: parent
                axis: Drag.XAxis
            }

            onReleased: {
                print('on release', zoomTrack.x, zoomTrack.width)
                zoomTrack.positionOrSizeChanged(zoomTrack.x, zoomTrack.width)
            }

            onMouseXChanged: {
                if (drag.active) {
                    zoomTrack.width = zoomTrack.width + mouseX
                    if (zoomTrack.width < zoomTrack.minWidth) {
                        zoomTrack.width = zoomTrack.minWidth
                    }
                }
            }
        }
    }

    Menu {
        id: contextMenu

        MenuItem {
            text: qsTr("Delete")
            onTriggered: {
                zoomTrackModel.deleteZoomTrack(index)
            }
        }

        MenuItem {
            text: qsTr("Delete all")
            onTriggered: {
                zoomTrackModel.deleteAllZoomTracks()
            }
        }
    }
}
