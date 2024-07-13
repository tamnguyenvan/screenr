import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls.Material 2.15

Item {
    id: gradientPage
    width: parent.width
    height: parent.height

    property var gradientColors: ["#4A249D", "#009FBD"]
    property string gradientType: "LinearGradient"
    property real gradientAngle: 0

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Rectangle {
            id: gradientPreview
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            Layout.margins: 10
            radius: 4

            Gradient {
                id: linearGradient
                orientation: (gradientAngle / 360 + 1)
                GradientStop {
                    position: 0.0
                    color: gradientColors[0]
                }
                GradientStop {
                    position: 1.0
                    color: gradientColors[1]
                }
            }
            gradient: gradientType === "LinearGradient" ? linearGradient : null
        }

        GridLayout {
            columns: 2
            Layout.fillWidth: true

            Label {
                text: "Angle:"
            }
            Slider {
                from: 0
                to: 360
                value: gradientAngle
                onValueChanged: gradientAngle = value
            }

            Label {
                text: "Color 1:"
            }
            Rectangle {
                width: 50
                height: 30
                color: gradientColors[0]
                radius: 4
                MouseArea {
                    anchors.fill: parent
                    onClicked: colorDialog1.open()
                }
            }

            Label {
                text: "Color 2:"
            }
            Rectangle {
                width: 50
                height: 30
                color: gradientColors[1]
                radius: 4
                MouseArea {
                    anchors.fill: parent
                    onClicked: colorDialog2.open()
                }
            }
        }

        CustomButton {
            text: "Apply"
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                videoController.background = {
                    "type": "gradient",
                    "value": {
                        "colors": gradientColors,
                        "angle": gradientAngle
                    }
                }
                if (!isPlaying) {
                    videoController.get_current_frame()
                }
            }
        }
    }

    ColorDialog {
        id: colorDialog1
        title: "Choose first color"
        onAccepted: {
            gradientColors = [colorToHexString(
                                  selectedColor), gradientColors[1]]
        }
    }

    ColorDialog {
        id: colorDialog2
        title: "Choose second color"
        onAccepted: {
            gradientColors = [gradientColors[0], colorToHexString(
                                  selectedColor)]
        }
    }

    function colorToHexString(color) {
        return "#" + Qt.rgba(color.r, color.g, color.b,
                             1).toString().substr(1, 6)
    }
}
