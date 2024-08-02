import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Effects
import Qt.labs.platform

Window {
    id: root
    visible: true
    width: 400
    height: 400
    x: (Screen.desktopAvailableWidth - width) / 2
    y: (Screen.desktopAvailableHeight - height) / 2
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"
    readonly property int countdownTime: 3

    Item {
        anchors.fill: parent
        Rectangle {
            id: countdown
            anchors.fill: parent
            color: "#303030"
            border.width: 3
            border.color: "#c4c4c4"
            radius: root.width / 2
            Timer {
                id: timer
                interval: 1000
                repeat: true
                running: true
                property int count: countdownTime
                onTriggered: {
                    count--
                    if (count == 0) {
                        timer.stop()
                        videoRecorder.start_recording()
                        tray.visible = true
                        root.visible = false
                    }
                }
            }
            Text {
                text: timer.count
                anchors.centerIn: parent
                font.pixelSize: 120
                font.weight: 700
                color: "white"
            }
        }
    }

    SystemTrayIcon {
        id: tray
        visible: false
        icon.source: "qrc:/resources/icons/screenr.ico"
        menu: Menu {
            MenuItem {
                text: qsTr("Stop")
                onTriggered: {
                    videoRecorder.stop_recording()
                    videoController.load_video(videoRecorder.output_path,
                                               videoRecorder.mouse_events)
                    studioLoader.source = ""
                    studioLoader.source = "qrc:/qml/studio/Studio.qml"
                    studioLoader.item.show()
                    tray.hide()
                }
            }
            MenuItem {
                text: qsTr("Cancel")
                onTriggered: {
                    videoRecorder.cancel_recording()
                    Qt.quit()
                }
            }
        }
    }

    Loader {
        id: studioLoader
    }
}
