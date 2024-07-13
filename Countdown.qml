import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Effects
import Qt.labs.platform

Window {
    id: countdownWindow
    visible: true
    width: 400
    height: 400
    x: (Screen.desktopAvailableWidth - width) / 2
    y: (Screen.desktopAvailableHeight - height) / 2
    title: "Countdown"

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
            radius: 80

            Timer {
                id: timer
                interval: 1000
                repeat: true
                running: true
                property int count: countdownTime
                onTriggered: {
                    count--
                    if (count == 0) {
                        // Stop the timer
                        timer.stop()

                        // Start recording
                        videoRecorder.start_recording()
                        tray.visible = true

                        // Hide the current window
                        countdownWindow.visible = false
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
        icon.source: "/home/tamnv/Projects/exp/screenr/resources/icons/custom.svg"

        menu: Menu {
            MenuItem {
                text: qsTr("Stop")
                onTriggered: {
                    videoRecorder.stop_recording()
                    print(videoRecorder.mouse_events)
                    videoController.load_video(videoRecorder.output_path,
                                               videoRecorder.mouse_events)

                    var component = Qt.createComponent(
                                "/home/tamnv/Projects/exp/screenr/Studio.qml")
                    if (component.status === Component.Ready) {
                        var studioWindow = component.createObject(null)

                        if (studioWindow === null) {
                            console.log("Error creating object")
                        }
                    } else {
                        console.log("Error loading component:",
                                    component.errorString())
                    }

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
}
