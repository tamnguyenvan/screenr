# This Python file uses the following encoding: utf-8
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from model import ZoomTrackModel, ZoomTrackItem, VideoController
from image_provider import FrameImageProvider


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    zoomtrack_model = ZoomTrackModel()

    # Image provider
    frame_provider = FrameImageProvider()
    engine.addImageProvider("frames", frame_provider)

    video_controller = VideoController(zoomtrack_model=zoomtrack_model, frame_provider=frame_provider)

    engine.rootContext().setContextProperty("zoomTrackModel", zoomtrack_model)
    engine.rootContext().setContextProperty("videoController", video_controller)

    qml_file = Path(__file__).resolve().parent / "main.qml"
    engine.load(qml_file)
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
