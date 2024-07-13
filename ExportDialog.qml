import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Dialog {
    id: exportDialog
    title: "Export"
    width: 800
    height: 600

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    modal: false
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property string currentSize: "720p"
    property var sizeMap: {
        "720p": [1280, 720],
        "1080p": [1920, 1080],
        "4K": [3840, 2160]
    }

    property string currentCompression: "Studio"
    property var compressionInfo: {
        "Studio": {
            "description": "Highest quality, best for further editing. Compression is almost impossible to notice.",
            "impact": "Quality setting does not impact export speed."
        },
        "Social Media": {
            "description": "High quality, optimized for social media platforms. Slight compression, barely noticeable.",
            "impact": "Quality setting may slightly reduce export time."
        },
        "Web": {
            "description": "Good quality, balanced for web viewing. Moderate compression, some loss in detail.",
            "impact": "Quality setting reduces export time and file size."
        },
        "Web (Low)": {
            "description": "Lower quality, optimized for fast loading. Higher compression, noticeable loss in quality.",
            "impact": "Quality setting significantly reduces export time and file size."
        }
    }

    property string exportFormat: "MP4"
    property int exportFps: 60
    property string exportCompression: "Studio"

    signal exportProgress(real progress)
    signal exportFinished

    background: Rectangle {
        color: "#1E1E1E"
        radius: 10
        border.color: "#3E3E3E"
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        Item {
            id: exportContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: true

            ColumnLayout {

                anchors.fill: parent
                spacing: 10

                RowLayout {
                    spacing: 50
                    RowLayout {
                        Text {
                            text: "Export as"
                            color: "white"
                        }
                        ComboBox {
                            id: formatComboBox
                            model: ["MP4", "GIF"]
                            currentIndex: 0
                            onCurrentTextChanged: exportFormat = currentText
                        }
                    }

                    RowLayout {
                        Text {
                            text: "Frame rate"
                            color: "white"
                        }
                        ComboBox {
                            id: fpsComboBox
                            model: ["60 FPS", "120 FPS", "24 FPS"]
                            currentIndex: 0
                            onCurrentTextChanged: exportFps = parseInt(
                                                      currentText.split(" ")[0])
                        }
                    }
                }

                RowLayout {
                    Text {
                        text: "Output Size"
                        color: "white"
                    }
                    RadioButton {
                        text: "720p"
                        checked: true
                        onCheckedChanged: if (checked)
                                              currentSize = "720p"
                    }
                    RadioButton {
                        text: "1080p"
                        onCheckedChanged: if (checked)
                                              currentSize = "1080p"
                    }
                    RadioButton {
                        text: "4K"
                        onCheckedChanged: if (checked)
                                              currentSize = "4K"
                    }
                }

                Text {
                    text: sizeMap[currentSize][0] + "px x " + sizeMap[currentSize][1] + "px"
                    color: "gray"
                }

                RowLayout {
                    Text {
                        text: "Quality (Compression level)"
                        color: "white"
                    }
                    ComboBox {
                        id: compressionComboBox
                        model: ["Studio", "Social Media", "Web", "Web (Low)"]
                        currentIndex: 0
                        onCurrentTextChanged: {
                            currentCompression = currentText
                            exportCompression = currentText
                        }
                    }
                }
                Text {
                    text: compressionInfo[currentCompression].description
                    color: "gray"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
                Text {
                    text: compressionInfo[currentCompression].impact
                    color: "gray"
                }

                Item {
                    Layout.fillHeight: true
                }

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 10
                    Button {
                        text: "Export to file"
                        highlighted: true
                        onClicked: {
                            var exportParams = {
                                "format": exportFormat.toLowerCase(),
                                "fps": exportFps,
                                "output_size": sizeMap[currentSize],
                                "compression_level": exportCompression
                            }
                            videoController.export_video(exportParams)
                            exportProgressBar.visible = true
                            cancelExportButton.visible = true
                        }
                    }
                    Button {
                        text: "Copy to clipboard"
                        onClicked: {

                            // Handle copy logic
                        }
                    }
                    Button {
                        text: "Cancel"
                        onClicked: exportDialog.close()
                    }
                }

                Text {
                    text: "Estimated export time — 6 seconds\nEstimated max output size — 20.8MB"
                    color: "gray"
                }

                ProgressBar {
                    id: exportProgressBar
                    visible: false
                    width: parent.width
                    from: 0
                    to: 100
                    value: 0
                }

                Button {
                    id: cancelExportButton
                    text: "Cancel Export"
                    visible: false
                    onClicked: {
                        videoController.cancel_export()
                        exportProgressBar.visible = false
                        cancelExportButton.visible = false
                    }
                }

                // Connections {
                //     target: videoController
                //     function onExportProgress(progress) {
                //         exportProgressBar.value = progress
                //     }
                //     function onExportFinished() {
                //         exportProgressBar.visible = false
                //         cancelExportButton.visible = false
                //     }
                // }
            }
        }

        Item {
            id: successContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: false

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    text: "Export Completed Successfully!"
                    color: "white"
                    font.pixelSize: 24
                    Layout.alignment: Qt.AlignHCenter
                }

                Button {
                    text: "Close"
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: exportDialog.close()
                }
            }
        }

        Connections {
            target: videoController
            function onExportProgress(progress) {
                exportProgressBar.value = progress
            }
            function onExportFinished() {
                exportContainer.visible = false
                successContainer.visible = true
            }
        }
    }
}
