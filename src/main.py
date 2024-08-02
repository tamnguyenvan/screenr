import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine

import rc_main
import rc_icons
import rc_images
from model import ZoomTrackModel, ZoomTrackItem, VideoController, VideoRecorder
from image_provider import FrameImageProvider


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)

    if getattr(sys, 'frozen', False):
        # Run from executable
        base_path = Path(sys._MEIPASS)
    else:
        # Run from source
        base_path = Path(__file__).parents[1]
    app.setWindowIcon(QIcon("resources/icons/screenr.ico"))
    engine = QQmlApplicationEngine()

    # Image provider
    frame_provider = FrameImageProvider()
    engine.addImageProvider("frames", frame_provider)

    # Models
    zoomtrack_model = ZoomTrackModel()
    video_controller = VideoController(zoomtrack_model=zoomtrack_model, frame_provider=frame_provider)
    video_recorder = VideoRecorder()

    engine.rootContext().setContextProperty("zoomTrackModel", zoomtrack_model)
    engine.rootContext().setContextProperty("videoController", video_controller)
    engine.rootContext().setContextProperty("videoRecorder", video_recorder)

    qml_file = "qrc:/qml/main.qml"
    engine.load(qml_file)
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
