import os
import time
from bisect import bisect_left
from threading import Thread, Event

import cv2
import numpy as np

from PySide6.QtCore import (
    QObject, Property, QAbstractListModel,
    QModelIndex, Qt, Slot, Signal, QThread, QTimer, QUrl
)
from PySide6.QtGui import QImage
from vidgear.gears import ScreenGear
from pynput.mouse import Listener

import transforms
from utils import generate_video_path


class ZoomTrackItem(QObject):
    def __init__(self, x, y, width, start_frame, track_len, click_x, click_y):
        super().__init__()
        self._x = x
        self._y = y
        self._width = width
        self._start_frame = start_frame
        self._track_len = track_len
        self._click_x = click_x
        self._click_y = click_y

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

    @width.setter
    def width(self, value):
        self._width = value

    @Property(int)
    def start_frame(self):
        return self._start_frame

    @start_frame.setter
    def start_frame(self, value):
        self._start_frame = value

    @Property(int)
    def track_len(self):
        return self._track_len

    @Property(float)
    def click_x(self):
        return self._click_x

    @Property(float)
    def click_y(self):
        return self._click_y


class ZoomTrackModel(QAbstractListModel):
    XRole = Qt.UserRole + 1
    YRole = Qt.UserRole + 2
    WidthRole = Qt.UserRole + 3
    StartFrameRole = Qt.UserRole + 4
    TrackLenRole = Qt.UserRole + 5
    ClickXRole = Qt.UserRole + 6
    ClickYRole = Qt.UserRole + 7

    zoomTracksChanged = Signal()

    def __init__(self, zoom_tracks=None, maximum_x=0):
        super().__init__()
        self._zoom_tracks = zoom_tracks or []
        self._maximum_x = maximum_x

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
        if role == ZoomTrackModel.StartFrameRole:
            return zoom_track.start_frame
        if role == ZoomTrackModel.TrackLenRole:
            return zoom_track.track_len
        if role == ZoomTrackModel.ClickXRole:
            return zoom_track.click_x
        if role == ZoomTrackModel.ClickYRole:
            return zoom_track.click_y

    def rowCount(self, parent=QModelIndex()):
        return len(self._zoom_tracks)

    def roleNames(self):
        roles = super().roleNames()
        roles[ZoomTrackModel.XRole] = b'x'
        roles[ZoomTrackModel.YRole] = b'y'
        roles[ZoomTrackModel.WidthRole] = b'width'
        roles[ZoomTrackModel.StartFrameRole] = b'start_frame'
        roles[ZoomTrackModel.TrackLenRole] = b'track_len'
        roles[ZoomTrackModel.ClickXRole] = b'click_x'
        roles[ZoomTrackModel.ClickYRole] = b'click_y'
        return roles

    @Slot(float, float, float, float, float, float)
    def addZoomTrack(self, x, width, start_frame, track_len, click_x=0.5, click_y=0.5):
        new_track = ZoomTrackItem(x, 0, width, start_frame, track_len, click_x, click_y)  # TODO:

        insert_index = bisect_left([track.x for track in self._zoom_tracks], x)

        self.beginInsertRows(QModelIndex(), insert_index, insert_index)
        self._zoom_tracks.insert(insert_index, new_track)
        self.endInsertRows()
        self.zoomTracksChanged.emit()

        # for zoom_track in self._zoom_tracks:
        #     print(zoom_track.x, zoom_track.width)
        # print('*' * 20)

    @Slot(list)
    def setZoomTracks(self, zoom_tracks):
        self.beginResetModel()
        self._zoom_tracks = [ZoomTrackItem(track['x'], track['y'], track['width'], track['start_frame'], track['track_len'], track['click_x'], track['click_y']) for track in zoom_tracks]
        self.endResetModel()
        self.zoomTracksChanged.emit()

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

    @Slot(int, int, int)
    def updateX(self, index, new_x, new_start_frame):
        if 0 <= index < len(self._zoom_tracks) and new_x >= 0 and new_start_frame >= 0:
            self._zoom_tracks[index].x = new_x
            self._zoom_tracks[index].start_frame = new_start_frame
            self.dataChanged.emit(self.index(index), self.index(index), [ZoomTrackModel.XRole, ZoomTrackModel.StartFrameRole])
            self.zoomTracksChanged.emit()

    @Slot(int, float)
    def updateWidth(self, index, new_width):
        if 0 <= index < len(self._zoom_tracks) and new_width > 0:
            self._zoom_tracks[index].width = new_width
            self.dataChanged.emit(self.index(index), self.index(index), [self.WidthRole])
            self.zoomTracksChanged.emit()

    @Slot(result=list)
    def getGaps(self):
        gaps = []
        last_end = 0

        for track in sorted(self._zoom_tracks, key=lambda t: t.x):
            if track.x > last_end:
                gaps.append({"x": last_end, "width": track.x - last_end})
            last_end = track.x + track.width

        if last_end < self.maximumX:
            gaps.append({"x": last_end, "width": self.maximumX - last_end})
        return gaps

    @Property(float)
    def maximumX(self):
        return self._maximum_x

    @maximumX.setter
    def maximumX(self, value):
        self._maximum_x = value
        self.zoomTracksChanged.emit()


class VideoRecorder(QObject):
    def __init__(self, output_path: str = None):
        super().__init__()
        self._output_path = output_path if output_path and os.path.exists(output_path) else generate_video_path()
        self._video_recording_thread = VideoRecordingThread(self._output_path)

    @Property(str)
    def output_path(self):
        return self._output_path

    @output_path.setter
    def output_path(self, value):
        self._output_path = value

    @Property(dict)
    def mouse_events(self):
        return self._video_recording_thread.mouse_events

    @Slot()
    def start_recording(self):
        self._video_recording_thread.start_recording()

    @Slot()
    def stop_recording(self):
        self._video_recording_thread.stop_recording()

    @Slot()
    def cancel_recording(self):
        self.stop_recording()
        if os.path.exists(self._output_path):
            os.remove(self._output_path)


class VideoRecordingThread:
    def __init__(self, output_path: str = None, start_delay: float = 0.5):
        self._output_path = output_path
        self._start_delay = start_delay
        self._record_thread = None
        self._mouse_track_thread = None
        self._mouse_events = {'move': [], 'click': []}
        self._writer = None
        self._frame_index = 0
        self._frame_width = None
        self._frame_height = None
        self._is_stopped = Event()
        self._is_stopped.set()
        self._fps = 25
        self._maximum_fps = 200

        self._stream = ScreenGear().start()

    @property
    def mouse_events(self):
        return self._mouse_events

    def start_recording(self):
        if not self._output_path:
            raise ValueError("Output path is not specified")

        self._is_stopped.clear()
        self._record_thread = Thread(target=self._recording)
        self._record_thread.start()

        self._mouse_track_thread = Thread(target=self._mouse_track)
        self._mouse_track_thread.start()

    def stop_recording(self):
        self._is_stopped.set()
        if self._record_thread is not None:
            self._record_thread.join()

        if self._mouse_track_thread is not None:
            self._mouse_track_thread.join()

    def cancel_recording(self):
        self.stop_recording()
        if self._output_path and os.path.exists(self._output_path):
            os.remove(self._output_path)

    @property
    def mouse_events(self):
        return self._mouse_events

    def _recording(self):
        try:
            time.sleep(self._start_delay)

            interval = 1 / self._fps
            self._frame_index = 0
            while not self._is_stopped.is_set():
                t0 = time.time()
                frame = self._stream.read()
                if frame is None:
                    break

                frame_height, frame_width = frame.shape[:2]
                if self._writer is None:
                    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
                    self._writer = cv2.VideoWriter(self._output_path, fourcc, self._fps, (frame_width, frame_height))
                    self._frame_width = frame_width
                    self._frame_height = frame_height

                self._frame_index += 1
                self._writer.write(frame)
                t1 = time.time()

                read_time = t1 - t0
                sleep_duration = max(0, interval - read_time)
                time.sleep(sleep_duration)

            print(f'Saved as {self._output_path}')
        except Exception as e:
            print(f"An error occurred: {e}")

        finally:
            if self._writer is not None:
                self._writer.release()
                self._writer = None
            self._stream.stop()

    def _mouse_track(self):
        def on_move(x, y):
            if self._frame_width is not None and self._frame_height is not None:
                relative_x = x / self._frame_width
                relative_y = y / self._frame_height
                self._mouse_events['move'].append((relative_x, relative_y, self._frame_index))

        def on_click(x, y, button, pressed):
            if pressed and self._frame_width is not None and self._frame_height is not None:
                relative_x = x / self._frame_width
                relative_y = y / self._frame_height
                self._mouse_events['click'].append((relative_x, relative_y, self._frame_index))

        with Listener(
            on_move=on_move,
            on_click=on_click,
        ):
            while True:
                self._is_stopped.wait()
                if self._is_stopped.is_set():
                    break
            print('Mouse listener stopped')


class VideoController(QObject):
    frameReady = Signal()
    playingChanged = Signal(bool)
    currentFrameChanged = Signal(int)

    exportProgress = Signal(float)
    exportFinished = Signal()

    def __init__(self, zoomtrack_model, frame_provider):
        super().__init__()
        self.video_processor = VideoProcessor()
        self.video_thread = VideoThread(self.video_processor)
        self.zoomtrack_model = zoomtrack_model
        self.frame_provider = frame_provider

        self.video_processor.frameProcessed.connect(self.on_frame_processed)
        self.video_processor.playingChanged.connect(self.on_playing_changed)
        self.zoomtrack_model.zoomTracksChanged.connect(self.on_zoomtracks_changed)

    @Property(int)
    def fps(self):
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

    @Property(dict)
    def background(self):
        return self.video_processor.background

    @background.setter
    def background(self, value):
        self.video_processor.background = value

    @Slot(str, dict)
    def load_video(self, path, recording_data):
        self.video_processor.load_video(path)

        # TODO: pixels_per_frame?
        pixels_per_frame = 6

        calib_mouse_events = {
            'move': [],
            'click': []
        }

        for click in recording_data['click']:
            click_x, click_y, start_frame = click
            x = start_frame * pixels_per_frame
            y = 0
            track_len = 1
            width = track_len * self.video_processor.fps * pixels_per_frame
            calib_mouse_events['move'].append({
                'x': x,
                'y': y,
                'width': width,
                'start_frame': start_frame,
                'track_len': 1,
                'click_x': click_x,
                'click_y': click_y
            })

        print('new', calib_mouse_events)
        self.zoomtrack_model.setZoomTracks(calib_mouse_events['move'])
        self.video_processor.mouse_events = calib_mouse_events

    @Slot()
    def toggle_play_pause(self):
        self.video_processor.toggle_play_pause()

    def on_playing_changed(self, is_playing):
        self.playingChanged.emit(is_playing)

    def on_zoomtracks_changed(self):
        # update the underlying data
        new_zoom_tracks = []
        for i in range(self.zoomtrack_model.rowCount()):
            index = self.zoomtrack_model.index(i, 0)
            new_zoom_tracks.append({
                'x': self.zoomtrack_model.data(index, ZoomTrackModel.XRole),
                'y': self.zoomtrack_model.data(index, ZoomTrackModel.YRole),
                'width': self.zoomtrack_model.data(index, ZoomTrackModel.WidthRole),
                'start_frame': self.zoomtrack_model.data(index, ZoomTrackModel.StartFrameRole),
                'track_len': self.zoomtrack_model.data(index, ZoomTrackModel.TrackLenRole),
                'click_x': self.zoomtrack_model.data(index, ZoomTrackModel.ClickXRole),
                'click_y': self.zoomtrack_model.data(index, ZoomTrackModel.ClickYRole),
            })

        self.video_processor.mouse_events['click'] = new_zoom_tracks

        self.video_processor.transforms['zoom'] = transforms.Zoom(
            click_data=new_zoom_tracks,
            fps=self.video_processor.fps
        )

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

    @Slot(int)
    def jump_to_frame(self, target_frame):
        self.video_processor.jump_to_frame(target_frame)

    @Slot()
    def get_current_frame(self):
        self.video_processor.get_current_frame()

    @Slot(dict)
    def export_video(self, export_params):
        self.export_thread = ExportThread(self.video_processor, export_params)
        self.export_thread.progress.connect(self.update_export_progress)
        self.export_thread.finished.connect(self.on_export_finished)
        self.export_thread.start()

    @Slot()
    def cancel_export(self):
        if self.export_thread and self.export_thread.isRunning():
            self.export_thread.terminate()
            self.export_thread.wait()
            self.exportFinished.emit()

    def update_export_progress(self, progress):
        self.exportProgress.emit(progress)

    def on_export_finished(self):
        self.exportFinished.emit()

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
        self._background = {'type': 'wallpaper', 'value': 0}
        self._mouse_events = {
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
    def background(self):
        return self._background

    @background.setter
    def background(self, value):
        self._background = value
        self.transforms['background'] = transforms.Background(background=value)

    @property
    def mouse_events(self):
        return self._mouse_events

    @mouse_events.setter
    def mouse_events(self, value):
        self._mouse_events = value

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
            'zoom': transforms.Zoom(click_data=self._mouse_events['click'], fps=self.fps),
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
    def jump_to_frame(self, target_frame):
        if self.video.isOpened() and 0 <= target_frame < self.total_frames:
            self.video.set(cv2.CAP_PROP_POS_FRAMES, target_frame)
            ret, frame = self.video.read()
            if ret:
                processed_frame = self.process_frame(frame)
                self.current_frame = target_frame
                self.frameProcessed.emit(processed_frame)

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
        transformed_result = self.transforms(input=frame, start_frame=self.current_frame)
        output_frame = transformed_result['input']

        output_frame = cv2.cvtColor(output_frame, cv2.COLOR_BGR2RGB)
        return output_frame


class VideoThread(QThread):
    def __init__(self, video_processor):
        super().__init__()
        self.video_processor = video_processor

    def run(self):
        self.video_processor.play()


class ExportThread(QThread):
    progress = Signal(float)
    finished = Signal()

    def __init__(self, video_processor, export_params):
        super().__init__()
        self.video_processor = video_processor
        self.export_params = export_params

    def run(self):
        format = self.export_params.get('format', 'mp4')
        fps = self.export_params.get('fps', self.video_processor.fps)
        output_size = self.export_params.get('output_size', (self.video_processor.frame_width, self.video_processor.frame_height))
        compression_level = self.export_params.get('compression_level', 'high')
        output_path = self.export_params.get('output_path', 'output_video')

        # Determine output file extension
        if format == 'mp4':
            output_path += '.mp4'
            fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        elif format == 'gif':
            output_path += '.gif'
            # For GIF, we'll use a different approach

        # Create VideoWriter object (for mp4)
        if format == 'mp4':
            out = cv2.VideoWriter(output_path, fourcc, fps, output_size)

        # Rewind video to start
        self.video_processor.video.set(cv2.CAP_PROP_POS_FRAMES, 0)

        frames = []
        total_frames = int(self.video_processor.video.get(cv2.CAP_PROP_FRAME_COUNT))

        for i in range(total_frames):
            ret, frame = self.video_processor.video.read()
            if ret:
                processed_frame = self.video_processor.process_frame(frame)

                # Resize frame if necessary
                if processed_frame.shape[:2] != output_size:
                    processed_frame = cv2.resize(processed_frame, output_size)

                if format == 'mp4':
                    out.write(cv2.cvtColor(processed_frame, cv2.COLOR_RGB2BGR))
                elif format == 'gif':
                    frames.append(Image.fromarray(processed_frame))

                self.progress.emit((i + 1) / total_frames * 100)
            else:
                break

        if format == 'mp4':
            out.release()
        elif format == 'gif':
            frames[0].save(output_path, save_all=True, append_images=frames[1:], duration=1000/fps, loop=0)

        self.finished.emit()
