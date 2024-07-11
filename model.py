import time
from bisect import bisect_left

import cv2
import numpy as np

from PySide6.QtCore import (
    QObject, Property, QAbstractListModel,
    QModelIndex, Qt, Slot, Signal, QThread, QTimer, QUrl
)
from PySide6.QtGui import QImage
import transforms


class ZoomTrackItem(QObject):
    def __init__(self, x, y, width, track_start, track_len):
        super().__init__()
        self._x = x
        self._y = y
        self._width = width
        self._track_start = track_start
        self._track_len = track_len

    @Property(int)
    def x(self):
        return self._x

    @x.setter
    def x(self, value):
        if self._x != value:
            self._x = value
            # self.xChanged.emit(self._x)

    @Property(int)
    def y(self):
        return self._y

    @Property(int)
    def width(self):
        return self._width

    @Property(int)
    def track_start(self):
        return self._track_start

    @Property(int)
    def track_len(self):
        return self._track_len


class ZoomTrackModel(QAbstractListModel):
    XRole = Qt.UserRole + 1
    YRole = Qt.UserRole + 2
    WidthRole = Qt.UserRole + 3
    TrackStartRole = Qt.UserRole + 4
    TrackLenRole = Qt.UserRole + 5

    zoomTracksChanged = Signal()

    def __init__(self, zoom_tracks=None):
        super().__init__()
        self._zoom_tracks = zoom_tracks or []

    def data(self, index, role):
        if not index.isValid():
            return None
        zoom_track = self._zoom_tracks[index.row()]
        if role == ZoomTrackModel.XRole:
            return zoom_track.x
        if role == ZoomTrackModel.YRole:
            return zoom_track.y
        if role == ZoomTrackModel.WidthRole:
            return zoom_track.width
        if role == ZoomTrackModel.TrackStartRole:
            return zoom_track.track_start
        if role == ZoomTrackModel.TrackLenRole:
            return zoom_track.track_len

    def rowCount(self, parent=QModelIndex()):
        return len(self._zoom_tracks)

    def roleNames(self):
        roles = super().roleNames()
        roles[ZoomTrackModel.XRole] = b'x'
        roles[ZoomTrackModel.YRole] = b'y'
        roles[ZoomTrackModel.WidthRole] = b'width'
        roles[ZoomTrackModel.TrackStartRole] = b'track_start'
        roles[ZoomTrackModel.TrackLenRole] = b'track_len'
        return roles

    @Slot(float, float)
    def addZoomTrack(self, x, width):
        new_track = ZoomTrackItem(x, 0, width, 0, 0)  # TODO:

        insert_index = bisect_left([track.x for track in self._zoom_tracks], x)

        self.beginInsertRows(QModelIndex(), insert_index, insert_index)
        self._zoom_tracks.insert(insert_index, new_track)
        self.endInsertRows()
        self.zoomTracksChanged.emit()

        # for zoom_track in self._zoom_tracks:
        #     print(zoom_track.x, zoom_track.width)
        # print('*' * 20)

    @Slot(int)
    def deleteZoomTrack(self, index):
        if 0 <= index < len(self._zoom_tracks):
            self.beginRemoveRows(QModelIndex(), index, index)
            del self._zoom_tracks[index]
            self.endRemoveRows()
            self.zoomTracksChanged.emit()

    @Slot()
    def deleteAllZoomTracks(self):
        if self._zoom_tracks:
            self.beginRemoveRows(QModelIndex(), 0, len(self._zoom_tracks) - 1)
            self._zoom_tracks.clear()
            self.endRemoveRows()
            self.zoomTracksChanged.emit()

    @Slot(int, int)
    def updateX(self, index, new_x):
        if 0 <= index < len(self._zoom_tracks) and new_x >= 0:
            self._zoom_tracks[index].x = new_x
            self.dataChanged.emit(self.index(index), self.index(index), [ZoomTrackModel.XRole])
            self.zoomTracksChanged.emit()

    @Slot(int, float)
    def updateWidth(self, index, new_width):
        if 0 <= index < len(self._zoom_tracks) and new_width > 0:
            self._zoom_tracks[index].width = new_width
            self.dataChanged.emit(self.index(index), self.index(index), [self.WidthRole])
            self.zoomTracksChanged.emit()

    @Slot(result='QVariantList')
    def getGaps(self):
        gaps = []
        total_width = 4000
        last_end = 0

        for track in sorted(self._zoom_tracks, key=lambda t: t.x):
            if track.x > last_end:
                gaps.append({"x": last_end, "width": track.x - last_end})
            last_end = track.x + track.width

        if last_end < total_width:
            gaps.append({"x": last_end, "width": total_width - last_end})
        return gaps


class VideoController(QObject):
    frameReady = Signal()
    playingChanged = Signal(bool)
    currentFrameChanged = Signal(int)

    def __init__(self, frame_provider):
        super().__init__()
        self.video_processor = VideoProcessor()
        self.video_thread = VideoThread(self.video_processor)
        self.frame_provider = frame_provider

        self.video_processor.frameProcessed.connect(self.on_frame_processed)
        self.video_processor.playingChanged.connect(self.on_playing_changed)

    @Property(int)
    def fps(self):
        print(self.video_processor.fps)
        return self.video_processor.fps

    @Property(int)
    def total_frames(self):
        return self.video_processor.total_frames

    @Property(float)
    def video_len(self):
        return self.video_processor.video_len

    @Property(int)
    def padding(self):
        return self.video_processor.padding

    @padding.setter
    def padding(self, value):
        self.video_processor.padding = value

    @Property(int)
    def border_radius(self):
        return self.video_processor.border_radius

    @border_radius.setter
    def border_radius(self, value):
        self.video_processor.border_radius = value

    @Slot(str)
    def load_video(self, path):
        self.video_processor.load_video(path)

    @Slot()
    def toggle_play_pause(self):
        self.video_processor.toggle_play_pause()

    def on_playing_changed(self, is_playing):
        self.playingChanged.emit(is_playing)

    @Slot()
    def play(self):
        if not self.video_thread.isRunning():
            self.video_thread.start()
        else:
            self.video_processor.play()

    @Slot()
    def pause(self):
        self.video_processor.pause()

    @Slot()
    def next_frame(self):
        self.video_processor.next_frame()

    @Slot()
    def prev_frame(self):
        self.video_processor.prev_frame()

    @Slot()
    def get_current_frame(self):
        self.video_processor.get_current_frame()

    def on_frame_processed(self, frame):
        height, width = frame.shape[:2]
        bytes_per_line = width * 3
        q_image = QImage(frame.data, width, height, bytes_per_line, QImage.Format_RGB888)
        self.currentFrameChanged.emit(self.video_processor.current_frame)
        self.frame_provider.updateFrame(q_image)
        self.frameReady.emit()


class VideoProcessor(QObject):
    frameProcessed = Signal(np.ndarray)
    playingChanged = Signal(bool)

    def __init__(self):
        super().__init__()
        self.video = None
        self._is_playing = False
        self.current_frame = 0
        self.play_timer = QTimer()
        self.play_timer.timeout.connect(self.process_next_frame)

        self._padding = 100
        self._inset = 0
        self._border_radius = 30
        self.mouse_events = {
            'click': [],
            'move': []
        }
        self.transforms = None

    @property
    def padding(self):
        return self._padding

    @padding.setter
    def padding(self, value):
        self._padding = value
        self.transforms['padding'] = transforms.Padding(padding=value)

    @property
    def border_radius(self):
        return self._border_radius

    @border_radius.setter
    def border_radius(self, value):
        self._border_radius = value
        self.transforms['roundness'] = transforms.Roundness(radius=value)

    @property
    def is_playing(self):
        return self._is_playing

    @is_playing.setter
    def is_playing(self, value):
        if self._is_playing != value:
            self._is_playing = value
            self.playingChanged.emit(value)

    @Slot(str)
    def load_video(self, path):
        self.video = cv2.VideoCapture(path)
        self.fps = int(self.video.get(cv2.CAP_PROP_FPS))
        self.frame_width = int(self.video.get(cv2.CAP_PROP_FRAME_WIDTH))
        self.frame_height = int(self.video.get(cv2.CAP_PROP_FRAME_HEIGHT))
        self.total_frames = int(self.video.get(cv2.CAP_PROP_FRAME_COUNT))
        self.video_len = self.total_frames / self.fps
        self.current_frame = 0

        background = {'type': 'wallpaper', 'value': 1}
        self.transforms = transforms.Compose({
            'aspect_ratio': transforms.AspectRatio('Auto'),
            'padding': transforms.Padding(padding=self.padding),
            'zoom': transforms.Zoom(click_data=self.mouse_events['click'], fps=self.fps),
            'roundness': transforms.Roundness(radius=self.border_radius),
            'shadow': transforms.Shadow(),
            'background': transforms.Background(background=background),
        })

        # Get first frame
        self.get_frame()

    @Slot()
    def get_frame(self):
        try:
            success, frame = self.video.read()
            if not success:
                return

            processed_frame = self.process_frame(frame)
            self.frameProcessed.emit(processed_frame)
            self.current_frame += 1
        except:
            return

    @Slot()
    def play(self):
        self.is_playing = True
        self.play_timer.start(1000 / self.fps)

    @Slot()
    def pause(self):
        self.is_playing = False
        self.play_timer.stop()

    @Slot()
    def toggle_play_pause(self):
        if self.is_playing:
            self.pause()
        else:
            self.play()

    @Slot()
    def next_frame(self):
        self.pause()
        if self.video.isOpened():
            ret, frame = self.video.read()
            if ret:
                processed_frame = self.process_frame(frame)
                self.frameProcessed.emit(processed_frame)
                self.current_frame += 1

    @Slot()
    def prev_frame(self):
        self.pause()
        if self.video.isOpened() and self.current_frame > 0:
            self.current_frame -= 1
            self.video.set(cv2.CAP_PROP_POS_FRAMES, self.current_frame)
            ret, frame = self.video.read()
            if ret:
                processed_frame = self.process_frame(frame)
                self.frameProcessed.emit(processed_frame)

    @Slot(int)
    def jump_to_frame(self, frame_index):
        if self.video.isOpened() and 0 <= frame_index < self.total_frames:
            self.video.set(cv2.CAP_PROP_POS_FRAMES, frame_index)
            ret, frame = self.video.read()
            if ret:
                processed_frame = self.process_frame(frame)
                self.frameProcessed.emit(processed_frame)
                self.current_frame = frame_index

    @Slot()
    def get_current_frame(self):
        if self.video is not None and self.video.isOpened():
            current_position = int(self.video.get(cv2.CAP_PROP_POS_FRAMES))

            ret, frame = self.video.read()

            if ret:
                processed_frame = self.process_frame(frame)

                self.video.set(cv2.CAP_PROP_POS_FRAMES, current_position)
                self.frameProcessed.emit(processed_frame)
                self.current_frame = current_position

    def process_next_frame(self):
        if self.video.isOpened():
            ret, frame = self.video.read()
            if ret:
                processed_frame = self.process_frame(frame)
                self.frameProcessed.emit(processed_frame)
                self.current_frame += 1
            else:
                self.pause()

    def process_frame(self, frame):
        transformed_result = self.transforms(input=frame, frame_index=self.current_frame)
        output_frame = transformed_result['input']

        output_frame = cv2.cvtColor(output_frame, cv2.COLOR_BGR2RGB)
        return output_frame


class VideoThread(QThread):
    def __init__(self, video_processor):
        super().__init__()
        self.video_processor = video_processor

    def run(self):
        self.video_processor.play()
