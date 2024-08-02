import QtQuick
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects
import QtQuick.Controls.Material 2.15
import "components"

Window {
    id: startupWindow
    visible: true
    width: Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight
    visibility: Window.FullScreen
    flags: Qt.FramelessWindowHint
    color: "transparent"

    property string selectedMode: "screen"
    property bool showCountdownFlag: false
    property bool showStudioFlag: false

    Item {
        id: homeItem
        anchors.fill: parent
        focus: true

        Rectangle {
            id: background
            anchors.fill: parent
            opacity: 0.0
        }

        Rectangle {
            id: border
            anchors.fill: parent
            border.width: 2
            border.color: "white"
            color: "transparent"
            visible: startupWindow.selectedMode == "screen"
        }

        CustomSelector {
            id: customSelector
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
        }

        Item {
            id: layout
            width: homeWidth + closeButtonSize / 2
            height: homeHeight + closeButtonSize / 2
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 80
            anchors.horizontalCenter: parent.horizontalCenter

            readonly property int homeWidth: 326
            readonly property int homeHeight: 220 // Increased height to accommodate two rows
            readonly property int closeButtonSize: 38

            Rectangle {
                id: home
                width: parent.homeWidth
                height: parent.homeHeight // Increased height
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#1c1c1c"
                radius: 30
                border.width: 1
                border.color: "#464646"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    // First row: Mode buttons
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height / 2
                        Layout.alignment: Qt.AlignCenter

                        ModeButton {
                            id: customButton
                            text: "Custom"
                            iconPath: "qrc:/resources/icons/custom.svg"
                            onClicked: {
                                customButton.activated = true
                                screenButton.activated = false
                                windowButton.activated = false
                                startupWindow.selectedMode = "custom"
                            }
                            Layout.preferredWidth: 90
                            Layout.preferredHeight: 80
                        }

                        ModeButton {
                            id: screenButton
                            text: "Screen"
                            iconPath: "qrc:/resources/icons/screen.svg"
                            activated: true
                            onClicked: {
                                customButton.activated = false
                                screenButton.activated = true
                                windowButton.activated = false
                                startupWindow.selectedMode = "screen"
                            }
                            Layout.preferredWidth: 90
                            Layout.preferredHeight: 80
                        }

                        ModeButton {
                            id: windowButton
                            text: "Window"
                            iconPath: "qrc:/resources/icons/window.svg"
                            onClicked: {
                                customButton.activated = false
                                screenButton.activated = false
                                windowButton.activated = true
                                startupWindow.selectedMode = "window"
                            }
                            Layout.preferredWidth: 90
                            Layout.preferredHeight: 80
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height / 2

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            RecordButton {
                                id: recordButton
                                anchors.centerIn: parent
                                onClicked: {
                                    countdownLoader.source = ""
                                    countdownLoader.source = "qrc:/qml/recording/Countdown.qml"
                                    startupWindow.hide()
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            CustomButton {
                                id: browseButton
                                Layout.preferredHeight: 40
                                Layout.preferredWidth: 40
                                anchors.centerIn: parent
                                primaryColor: "#212121"
                                hoverColor: "#242424"
                                buttonRadius: 20

                                iconSource: "qrc:/resources/icons/folder.svg"

                                onClicked: {
                                    var videoPath = "/home/tamnv/Downloads/upwork-contract-exporter.mp4"
                                    var mouseEvents = {
                                        "click": [],
                                        "move": []
                                    }
                                    videoController.load_video(videoPath,
                                                               mouseEvents)

                                    // var component = Qt.createComponent(
                                    //             "qrc:/qml/studio/Studio.qml")
                                    // if (component.status === Component.Ready) {
                                    //     var studioWindow = component.createObject(
                                    //                 null)

                                    //     if (studioWindow === null) {
                                    //         console.log("Error creating object")
                                    //     }
                                    // } else {
                                    //     console.log("Error loading component:",
                                    //                 component.errorString())
                                    // }
                                    studioLoader.source = ""
                                    studioLoader.source = "qrc:/qml/studio/Studio.qml"

                                    startupWindow.hide()
                                }
                            }
                        }
                    }
                }
            }

            Button {
                id: closeButton
                anchors.top: parent.top
                anchors.left: parent.left
                width: layout.closeButtonSize
                height: layout.closeButtonSize
                z: 1

                background: Rectangle {
                    anchors.fill: parent
                    radius: layout.closeButtonSize / 2
                    color: closeButton.hovered ? Qt.lighter("#393939",
                                                            1.2) : "#393939"
                    border.width: 1
                    border.color: "#404040"
                }

                contentItem: Image {
                    source: "qrc:/resources/icons/close.svg"
                    anchors.centerIn: parent
                    sourceSize.height: 16
                    sourceSize.width: 16
                }

                onClicked: close()
            }

            MultiEffect {
                source: home
                anchors.fill: home
                shadowBlur: 1.0
                shadowEnabled: true
                shadowColor: "black"
                shadowVerticalOffset: 0
                shadowHorizontalOffset: 0
            }
        }

        Dialog {
            id: browseVideoDialog
        }

        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) {
                                close()
                            }
                        }
    }

    Loader {
        id: countdownLoader
    }

    Loader {
        id: studioLoader
    }
}
