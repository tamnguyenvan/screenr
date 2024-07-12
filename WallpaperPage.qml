import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: wallpaperPage
    width: parent.width
    height: 200

    GridLayout {
        anchors.fill: parent
        columns: 7
        anchors.margins: 10

        Repeater {
            model: 20

            Image {
                source: "/home/tamnv/Projects/exp/screenr/resources/images/wallpaper/thumbnail/gradient-wallpaper-" + (index + 1).toString(
                            ).padStart(4, '0') + ".png"

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        videoController.background = {
                            "type": "wallpaper",
                            "value": index
                        }
                        if (!isPlaying) {
                            videoController.get_current_frame()
                        }
                    }
                }
            }
        }
    }
}
