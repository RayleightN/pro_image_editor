import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// A mixin for handling thumbnail generation and video editing states.
///
/// This mixin stores video thumbnails and manages playback and trim states.
mixin ThumbnailGeneratorMixin {
  /// Video editor configuration settings.
  final VideoEditorConfigs videoConfigs = const VideoEditorConfigs(
    initialMuted: true,
    initialPlay: false,
    minTrimDuration: Duration(seconds: 7),
  );

  /// Indicates whether a seek operation is in progress.
  bool isSeeking = false;

  /// Stores the currently selected trim duration span.
  TrimDurationSpan? durationSpan;

  /// Temporarily stores a pending trim duration span.
  TrimDurationSpan? tempDurationSpan;

  /// Controls video playback and trimming functionalities.
  ProVideoController? proVideoController;

  Duration? totalVideoDuration;

  /// Stores generated thumbnails for the trimmer bar and filter background.
  final List<ImageProvider> thumbnails = [];

  final int _thumbnailCount = 7;

  Future<String> _saveVideoToCache(Uint8List videoData) async {
    final tempDir = await getTemporaryDirectory();

    // Detect MIME type
    String? mimeType = lookupMimeType('', headerBytes: videoData);
    String extension =
        mimeType != null ? (extensionFromMime(mimeType) ?? 'mp4') : 'mp4';

    final videoFile = File('${tempDir.path}/pro_video_editor.$extension');

    await videoFile.writeAsBytes(videoData);
    return videoFile.path;
  }

  /// Generates a series of video thumbnails at evenly spaced intervals.
  ///
  /// This method extracts `_thumbnailCount` number of frames from a given video
  /// file and stores them as `MemoryImage` instances in the `thumbnails` list.
  /// The thumbnails are generated only on Android and iOS platforms; for other
  /// platforms, a debug message is printed suggesting an alternative approach.
  ///
  /// ### Supported Platforms:
  /// - ✅ Android
  /// - ✅ iOS
  /// - ❌ Web, Windows, macOS, Linux (Not supported)
  ///
  /// If used on an unsupported platform, consider implementing a server-side
  /// solution using FFmpeg, such as with Firebase Functions.
  ///
  /// ### Parameters:
  /// - [bytes]: The raw video file data in `Uint8List` format.
  /// - [duration]: The total duration of the video.
  /// - [editorWidth]: The width of the video editor UI, used to determine
  ///   thumbnail sizes.
  /// - [pixelRatio]: The pixel density of the device to ensure
  ///   high-resolution thumbnails.
  ///
  /// ### Process:
  /// 1. Saves the video file to a temporary cache.
  /// 2. Calculates the interval step between frames.
  /// 3. Extracts thumbnails using the `VideoThumbnail` package.
  /// 4. Stores the generated thumbnails in `thumbnails`.
  /// ```
  Future<void> generateThumbnails({
    required Uint8List bytes,
    required Duration duration,
    required double editorWidth,
    required double pixelRatio,
  }) async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      int videoDuration = duration.inMilliseconds;
      int firstPosition = 1000;
      double step = (videoDuration - firstPosition) / (_thumbnailCount - 1);
      String videoPath = await _saveVideoToCache(bytes);

      for (var i = 0; i < _thumbnailCount; i++) {
        double position = firstPosition + (i * step);

        final thumbnail = await VideoThumbnail.thumbnailData(
          video: videoPath,
          maxWidth: (editorWidth / _thumbnailCount * pixelRatio).toInt(),
          imageFormat: ImageFormat.PNG,
          timeMs: position.toInt(),
        );

        thumbnails.add(MemoryImage(thumbnail));
      }
    } else {
      debugPrint('Native thumbnail generation is not yet supported on that '
          'platform. If you need to display thumbnails, you could set up a '
          'function similar to firebase-functions in combination with the '
          'ffmpeg npm package.');
    }
  }
}
