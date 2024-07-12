import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs

Item {
    id: colorPage
    width: parent.width
    height: 200

    GridLayout {
        anchors.fill: parent
        columns: 7
        rowSpacing: 5
        columnSpacing: 5

        Repeater {
            model: ['#FF3131', '#FF5757', '#FF66C4', '#CB6CE6', '#8C52FF', '#5E17EB', '#0097B2', '#0CC0DF', '#5CE1E6', '#38B6FF', '#5271FF', '#004AAD', '#00BF63', '#7ED957', '#C1FF72', '#FFDE59', '#FFBD59', '#FF914D', '#FA7420', '#5E17EB']
            delegate: Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 50
                Layout.preferredWidth: 50
                color: modelData
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        videoController.background = {
                            "type": "color",
                            "value": modelData
                        }
                        if (!isPlaying) {
                            videoController.get_current_frame()
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            color: "white"
            border.color: "black"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "+"
                font.pixelSize: 24
            }

            MouseArea {
                anchors.fill: parent
                onClicked: colorDialog.open()
            }
        }
    }

    ColorDialog {
        id: colorDialog
        title: "Choose a color"
        onAccepted: {
            var hexColor = "#" + colorDialog.selectedColor.toString().substr(1)
            videoController.background = {
                "type": "color",
                "value": hexColor
            }
            if (!isPlaying) {
                videoController.get_current_frame()
            }
        }
    }
}
