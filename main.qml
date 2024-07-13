import QtQuick
import QtQuick.Controls 2.5
import QtQuick.Window 2.15
import QtQuick.Layouts
import QtQuick.Effects

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

    Item {
        id: homeItem
        anchors.fill: parent
        focus: true

        Rectangle {
            id: background
            anchors.fill: parent
            opacity: 0.0
        }

        // Border in screen mode
        Rectangle {
            id: border
            anchors.fill: parent
            border.width: 2
            border.color: "white"
            color: "transparent"
            visible: startupWindow.selectedMode == "screen"
        }

        // Area selector for custom mode
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
            readonly property int homeHeight: 174
            readonly property int closeButtonSize: 38

            // Home
            Rectangle {
                id: home
                width: 326
                height: 174
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter

                color: "#1c1c1c"
                radius: 30
                border.width: 1
                border.color: "#464646"

                Row {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 18
                    spacing: 8

                    ModeButton {
                        id: customButton
                        text: "Custom"
                        iconPath: "/home/tamnv/Projects/exp/screenr/resources/icons/custom.svg"
                        onClicked: {
                            customButton.activated = true
                            screenButton.activated = false
                            windowButton.activated = false
                            startupWindow.selectedMode = "custom"
                        }
                    }

                    ModeButton {
                        id: screenButton
                        text: "Screen"
                        iconPath: "/home/tamnv/Projects/exp/screenr/resources/icons/screen.svg"
                        activated: true
                        onClicked: {
                            customButton.activated = false
                            screenButton.activated = true
                            windowButton.activated = false
                            startupWindow.selectedMode = "screen"
                        }
                    }

                    ModeButton {
                        id: windowButton
                        text: "Window"
                        iconPath: "/home/tamnv/Projects/exp/screenr/resources/icons/window.svg"
                        onClicked: {
                            customButton.activated = false
                            screenButton.activated = false
                            windowButton.activated = true
                            startupWindow.selectedMode = "window"
                        }
                    }
                }

                Row {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: 10

                    RecordButton {
                        id: recordButton
                        onClicked: {
                            countdownLoader.source = ""
                            countdownLoader.source
                                    = "/home/tamnv/Projects/exp/screenr/Countdown.qml"
                            startupWindow.hide()
                        }
                    }
                }
            }

            // Close button
            Item {
                anchors.top: parent.top
                anchors.left: parent.left
                width: layout.closeButtonSize
                height: layout.closeButtonSize
                z: 1

                Button {
                    id: closeButton
                    anchors.fill: parent

                    background: Rectangle {
                        anchors.fill: parent
                        radius: layout.closeButtonSize / 2
                        color: closeButton.hovered ? Qt.lighter("#393939",
                                                                1.2) : "#393939"
                        border.width: 1
                        border.color: "#404040"
                    }

                    contentItem: Item {
                        anchors.fill: parent
                        Image {
                            source: "/home/tamnv/Projects/exp/screenr/resources/icons/close.svg"
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                        }
                    }

                    onClicked: {
                        close()
                    }
                }
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

        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) {
                                close()
                            }
                        }
    }

    Loader {
        id: countdownLoader
    }
}
