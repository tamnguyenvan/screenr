import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

ApplicationWindow {
    id: root
    width: 1280
    height: 800
    visible: true
    title: qsTr("ScreenR")

    visibility: Window.Maximized

    Material.theme: Material.Dark
    Material.accent: Material.LightBlue

    property bool isPlaying: false
    property int fps: 30
    property int totalFrames: 0
    property int pixelsPerFrame: 6
    property real videoLen: 0

    Connections {
        target: videoController
        function onPlayingChanged(playing) {
            isPlaying = playing
        }
    }

    ExportDialog {
        id: exportDialog
        parent: Overlay.overlay
    }

    Rectangle {
        anchors.fill: parent
        color: "#0B0D0F"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 0

            // Top bar
            RowLayout {
                Layout.fillWidth: true
                Layout.maximumHeight: 50

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                CustomButton {
                    text: "Export"
                    iconSource: "/home/tamnv/Projects/exp/screenr/resources/icons/export.svg"
                    iconSize: 20
                    primaryColor: "#4329F4"

                    onClicked: {
                        exportDialog.open()
                    }
                }
            }

            // Main content
            RowLayout {
                id: mainContent
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // Video preview label (placeholder for now)
                    Image {
                        id: videoPreview
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        fillMode: Image.PreserveAspectFit

                        onStatusChanged: {
                            if (status === Image.Error) {
                                console.error("Error loading image:", source)
                            }
                        }

                        Connections {
                            target: videoController
                            function onFrameReady(frame) {
                                videoPreview.source = "image://frames/frame?" + Date.now()
                            }
                        }
                    }

                    // Controll buttons
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.maximumHeight: 50
                        Layout.alignment: Qt.AlignHCenter

                        RowLayout {
                            CustomButton {
                                iconSource: "/home/tamnv/Projects/exp/screenr/resources/icons/prev.svg"
                                primaryColor: "transparent"
                                hoverColor: "#212121"
                                onClicked: videoController.prev_frame()
                            }

                            CustomButton {
                                iconSource: isPlaying ? "/home/tamnv/Projects/exp/screenr/resources/icons/pause.svg" : "/home/tamnv/Projects/exp/screenr/resources/icons/play.svg"
                                primaryColor: "transparent"
                                hoverColor: "#212121"
                                onClicked: videoController.toggle_play_pause()
                            }

                            CustomButton {
                                iconSource: "/home/tamnv/Projects/exp/screenr/resources/icons/next.svg"
                                primaryColor: "transparent"
                                hoverColor: "#212121"
                                onClicked: videoController.next_frame()
                            }
                        }

                        RowLayout {
                            CustomButton {
                                iconSource: "/home/tamnv/Projects/exp/screenr/resources/icons/cut.svg"
                                primaryColor: "transparent"
                                hoverColor: "#212121"
                            }

                            CustomButton {
                                iconSource: "/home/tamnv/Projects/exp/screenr/resources/icons/scale.svg"
                                primaryColor: "transparent"
                                hoverColor: "#212121"
                            }
                        }
                    }
                }

                // SideBar
                ColumnLayout {
                    Layout.preferredWidth: 450
                    Layout.minimumWidth: 450
                    Layout.fillHeight: true

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        radius: 20
                        color: "#131519"

                        ScrollView {
                            anchors.fill: parent

                            contentWidth: parent.width
                            contentHeight: 1000
                            clip: true

                            Column {
                                anchors.fill: parent
                                anchors.leftMargin: 20
                                anchors.rightMargin: 20
                                anchors.topMargin: 30
                                anchors.bottomMargin: 30
                                spacing: 40

                                // Background settings
                                ColumnLayout {
                                    width: parent.width
                                    spacing: 10

                                    Row {
                                        spacing: 8
                                        Image {
                                            // anchors.bottom: parent.bottom
                                            source: "/home/tamnv/Projects/exp/screenr/resources/icons/background.svg"
                                            sourceSize.width: 24
                                            sourceSize.height: 24
                                            Layout.alignment: Qt.AlignVCenter
                                            visible: true
                                        }
                                        Label {
                                            text: qsTr("Background")
                                            font.pixelSize: 16
                                            anchors.bottom: parent.bottom
                                        }
                                    }

                                    TabBar {
                                        id: backgroundSettingsBar
                                        width: parent.width

                                        Repeater {
                                            model: ["Wallpaper", "Gradient", "Color", "Image"]

                                            TabButton {
                                                text: modelData
                                                width: implicitWidth
                                            }
                                        }
                                    }

                                    StackLayout {
                                        width: parent.width
                                        currentIndex: backgroundSettingsBar.currentIndex

                                        WallpaperPage {
                                            id: wallpaperPage
                                        }

                                        GradientPage {
                                            id: gradientPage
                                        }

                                        ColorPage {
                                            id: colorPage
                                        }

                                        ImagePage {
                                            id: imagePage
                                        }
                                    }
                                }

                                // Shape settings
                                ColumnLayout {
                                    spacing: 20

                                    Label {
                                        text: qsTr("Shape")
                                        color: "#c2c2c2"
                                    }
                                    ColumnLayout {
                                        spacing: 50

                                        // Padding
                                        ColumnLayout {
                                            width: parent.width

                                            Row {
                                                spacing: 8
                                                Image {
                                                    // anchors.bottom: parent.bottom
                                                    source: "/home/tamnv/Projects/exp/screenr/resources/icons/padding.svg"
                                                    sourceSize.width: 24
                                                    sourceSize.height: 24
                                                    Layout.alignment: Qt.AlignVCenter
                                                    visible: true
                                                }
                                                Label {
                                                    text: qsTr("Padding")
                                                    font.pixelSize: 16
                                                    anchors.bottom: parent.bottom
                                                }
                                            }

                                            RowLayout {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true

                                                Slider {
                                                    id: paddingSlider
                                                    from: 0
                                                    value: 100
                                                    to: 500
                                                    Layout.preferredWidth: 380

                                                    onValueChanged: {
                                                        paddingLabel.updateText(
                                                                    value)
                                                        videoController.padding = Math.round(
                                                                    value)
                                                        if (!isPlaying) {
                                                            videoController.get_current_frame()
                                                        }
                                                    }
                                                }

                                                Label {
                                                    id: paddingLabel
                                                    text: "100"
                                                    function updateText(value) {
                                                        text = value.toFixed(0)
                                                    }
                                                }
                                            }
                                        }

                                        // Inset
                                        ColumnLayout {
                                            width: parent.width

                                            Row {
                                                spacing: 8
                                                Image {
                                                    // anchors.bottom: parent.bottom
                                                    source: "/home/tamnv/Projects/exp/screenr/resources/icons/padding.svg"
                                                    sourceSize.width: 24
                                                    sourceSize.height: 24
                                                    Layout.alignment: Qt.AlignVCenter
                                                    visible: true
                                                }
                                                Label {
                                                    text: qsTr("Inset")
                                                    font.pixelSize: 16
                                                    anchors.bottom: parent.bottom
                                                }
                                            }

                                            RowLayout {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true

                                                Slider {
                                                    id: insetSlider
                                                    from: 0
                                                    value: 100
                                                    to: 500
                                                    Layout.preferredWidth: 380
                                                }

                                                Label {
                                                    text: qsTr("%1").arg(
                                                              Math.round(
                                                                  insetSlider.value))
                                                }
                                            }
                                        }

                                        // Roundness
                                        ColumnLayout {
                                            width: parent.width

                                            Row {
                                                spacing: 8
                                                Image {
                                                    // anchors.bottom: parent.bottom
                                                    source: "/home/tamnv/Projects/exp/screenr/resources/icons/border.svg"
                                                    sourceSize.width: 24
                                                    sourceSize.height: 24
                                                    Layout.alignment: Qt.AlignVCenter
                                                    visible: true
                                                }
                                                Label {
                                                    text: qsTr("Roundness")
                                                    font.pixelSize: 16
                                                    anchors.bottom: parent.bottom
                                                }
                                            }

                                            RowLayout {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true

                                                Slider {
                                                    id: roundnessSlider
                                                    from: 0
                                                    value: 20
                                                    to: 100
                                                    Layout.preferredWidth: 380

                                                    onValueChanged: {
                                                        roundnessLabel.updateText(
                                                                    value)
                                                        videoController.border_radius = Math.round(
                                                                    value)
                                                        if (!isPlaying) {
                                                            videoController.get_current_frame()
                                                        }
                                                    }
                                                }

                                                Label {
                                                    id: roundnessLabel
                                                    text: "20"

                                                    function updateText(value) {
                                                        text = value.toFixed(0)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Video edit
            Rectangle {
                id: videoEdit
                Layout.fillWidth: true
                Layout.preferredHeight: 230
                color: "transparent"
                radius: 4

                ScrollView {
                    anchors.fill: parent

                    contentWidth: root.fps * root.videoLen * root.pixelsPerFrame + 200
                    contentHeight: parent.height

                    // Container
                    Item {
                        width: parent.contentWidth
                        height: videoEdit.height
                        anchors.left: parent.left
                        anchors.leftMargin: 20

                        // Timeline
                        Repeater {
                            model: Math.ceil(root.videoLen) + 1

                            Item {
                                width: root.fps * root.pixelsPerFrame
                                height: 60
                                x: root.fps * root.pixelsPerFrame * index
                                y: 10

                                readonly property int timeLabelWidth: 20

                                Item {
                                    width: parent.timeLabelWidth
                                    height: parent.height

                                    ColumnLayout {
                                        anchors.fill: parent
                                        spacing: 10

                                        Item {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                        }

                                        Label {
                                            Layout.alignment: Qt.AlignCenter
                                            text: qsTr("" + index)
                                        }

                                        Item {
                                            Layout.alignment: Qt.AlignCenter

                                            Rectangle {
                                                width: 4
                                                height: 4
                                                radius: 2
                                                color: "white"
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Item {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                        }
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        print('timeline',
                                              root.fps * root.pixelsPerFrame * index
                                              + mouseX - parent.timeLabelWidth / 2)
                                        var xPos = Math.max(
                                                    0,
                                                    root.fps * root.pixelsPerFrame * index + mouseX
                                                    - parent.timeLabelWidth / 2)
                                        var currentFrame = Math.round(
                                                    xPos / root.pixelsPerFrame)
                                        videoController.jump_to_frame(
                                                    currentFrame)
                                    }
                                }
                            }
                        }

                        // Clip track
                        Item {
                            width: parent.width
                            height: 60
                            y: 75
                            anchors.left: parent.left
                            anchors.leftMargin: 10

                            ClipTrack {
                                x: 0
                                y: 0
                                height: 60
                                width: root.fps * root.pixelsPerFrame * root.videoLen
                                videoLen: root.videoLen

                                onLeftMouseClicked: function (mouseX) {
                                    // Update the frame
                                    var targetFrame = Math.round(
                                                (x + mouseX - timeSlider.width
                                                 / 2) / root.pixelsPerFrame)
                                    videoController.jump_to_frame(targetFrame)
                                }
                            }
                        }

                        // Zoom tracks
                        Item {
                            width: parent.width
                            height: 60
                            y: 150
                            anchors.left: parent.left
                            anchors.leftMargin: 10

                            Repeater {
                                model: zoomTrackModel
                                property int zoomTrackStartX: 0

                                delegate: ZoomTrack {
                                    width: model.width
                                    height: 60
                                    x: model.x
                                    y: 0

                                    onPositionOrSizeChanged: (newX, newWidth) => {
                                                                 var newStartFrame = Math.round(
                                                                     newX / root.pixelsPerFrame)

                                                                 zoomTrackModel.updateX(
                                                                     index,
                                                                     newX,
                                                                     newStartFrame)
                                                                 zoomTrackModel.updateWidth(
                                                                     index,
                                                                     newWidth)
                                                             }

                                    onLeftMouseClicked: function (mouseX) {
                                        var targetFrame = Math.round(
                                                    (x + mouseX - timeSlider.width
                                                     / 2) / root.pixelsPerFrame)
                                        videoController.jump_to_frame(
                                                    targetFrame)
                                    }
                                }
                            }
                        }

                        // TimeSlider
                        TimeSlider {
                            id: timeSlider
                            x: 0
                            y: 0

                            Connections {
                                target: videoController
                                function onCurrentFrameChanged(currentFrame) {
                                    timeSlider.x = currentFrame * root.pixelsPerFrame
                                }
                            }
                        }

                        // NonZoomTrackMouseArea
                        Repeater {
                            id: nonZoomTracksRepeater
                            model: zoomTrackModel ? zoomTrackModel.getGaps(
                                                        ) : []
                            delegate: NonZoomTrackMouseArea {
                                x: modelData.x
                                y: 150
                                width: modelData.width
                                height: 60

                                onMouseEntered: function (mouseX) {
                                    hoverZoomTrack.x = x + mouseX
                                    hoverZoomTrack.visible = true

                                    timeIndicator.x = x + mouseX
                                    timeIndicator.visible = true
                                }

                                onMouseExited: {
                                    hoverZoomTrack.visible = false
                                    timeIndicator.visible = false
                                }

                                onClicked: function (clickX) {
                                    hoverZoomTrack.visible = false
                                    timeIndicator.visible = false

                                    var startFrame = Math.round(
                                                (x + clickX) / root.pixelsPerFrame)
                                    var trackLen = 1.5

                                    zoomTrackModel.addZoomTrack(
                                                x + clickX,
                                                hoverZoomTrack.width,
                                                startFrame, trackLen)
                                }
                            }
                        }

                        Connections {
                            target: zoomTrackModel
                            function onZoomTracksChanged() {
                                if (zoomTrackModel) {
                                    nonZoomTracksRepeater.model = zoomTrackModel.getGaps()
                                }
                            }
                        }

                        // HoverZoomTrack
                        HoverZoomTrack {
                            id: hoverZoomTrack
                            x: 0
                            y: 150
                            width: 1.5 * root.fps * root.pixelsPerFrame
                            height: 60
                            visible: false
                        }

                        // Time indicator
                        TimeSlider {
                            id: timeIndicator
                            x: 0
                            y: -10
                            color: "#22242F"
                            visible: false
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        fps = videoController.fps
        totalFrames = videoController.total_frames
        videoLen = videoController.video_len
        zoomTrackModel.maximumX = totalFrames * pixelsPerFrame

        videoController.get_current_frame()
    }
}
