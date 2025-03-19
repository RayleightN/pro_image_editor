import 'dart:async';
import 'dart:typed_data';

import 'package:example/core/constants/example_constants.dart';
import 'package:example/core/mixin/example_helper.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class VideoMediaKitExample extends StatefulWidget {
  const VideoMediaKitExample({super.key});

  @override
  State<VideoMediaKitExample> createState() => _VideoMediaKitExampleState();
}

class _VideoMediaKitExampleState extends State<VideoMediaKitExample>
    with ExampleHelperState<VideoMediaKitExample> {
  /// Ensure that you have called `MediaKit.ensureInitialized();` in the
  /// main method.

  late final _player = Player();
  late final _controller = VideoController(_player);

  final _fileSize = '1.5MB';

  late VideoEditorConfigs _configs = VideoEditorConfigs(
    infoBannerText: '00:00 | $_fileSize',
    initialMuted: false,
    initialPlay: false,
  );
  ProVideoController? _proVideoController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _initializePlayer() async {
    await _player.open(Media(kVideoEditorExampleAssetPath), play: false);
    await _player.setPlaylistMode(PlaylistMode.loop);

    Completer<void> durationCompleter = Completer();
    Completer<void> resolutionCompleter = Completer();
    Size initialSize = Size.zero;

    _player.stream.duration.listen((event) {
      if (!mounted) return;

      _configs = _configs.copyWith(
        infoBannerText: '${_formatDuration(event)} | $_fileSize',
      );

      if (!durationCompleter.isCompleted) {
        durationCompleter.complete();
      }
      setState(() {});
    });
    _player.stream.width.listen((event) {
      if (!mounted) return;

      initialSize = Size(
        _player.state.width?.toDouble() ?? 0,
        _player.state.height?.toDouble() ?? 0,
      );

      if (!resolutionCompleter.isCompleted) {
        resolutionCompleter.complete();
      }
      setState(() {});
    });

    await durationCompleter.future;
    await resolutionCompleter.future;

    _proVideoController = ProVideoController(
      videoPlayer: _buildVideoPlayer(),
      initialSize: initialSize,
    );

    /*    ..stream.duration.listen((event) {
        print(event);
        if (!mounted) return;

        _configs = _configs.copyWith(
          infoBannerText: '${_formatDuration(event)} | $_fileSize',
        );

        setState(() {});
      })
      ..stream.width.listen((event) {
        print(Size(
          _player.state.width?.toDouble() ?? 0,
          _player.state.height?.toDouble() ?? 0,
        ));
      }); */
/*
    TODO: duration
    _player.state.duration;
    TODO: resolution
    Size(
      _player.state.width?.toDouble() ?? 0,
      _player.state.height?.toDouble() ?? 0,
    );
    */
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      String hours = twoDigits(duration.inHours);
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: _proVideoController == null
          ? _buildProcessing()
          : ProImageEditor.video(
              _proVideoController!,
              callbacks: ProImageEditorCallbacks(
                videoEditorCallbacks: VideoEditorCallbacks(
                  onPause: _player.pause,
                  onPlay: _player.play,
                  onMuteToggle: (isMuted) {
                    _player.setVolume(isMuted ? 0 : 100);
                  },
                ),
              ),
              configs: ProImageEditorConfigs(
                mainEditor: MainEditorConfigs(
                  widgets: MainEditorWidgets(
                    removeLayerArea: (removeAreaKey, editor, rebuildStream) =>
                        VideoEditorRemoveArea(
                      removeAreaKey: removeAreaKey,
                      editor: editor,
                      rebuildStream: rebuildStream,
                    ),
                  ),
                ),
                videoEditor: _configs,
              ),
            ),
    );
  }

  Widget _buildVideoPlayer() {
    return Video(
      key: const ValueKey('Video-Player'),
      controller: _controller,
      controls: null,
    );
  }

  Widget _buildProcessing() {
    return Scaffold(
      body: Stack(
        children: [
          Offstage(child: _buildVideoPlayer()),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blueGrey.shade900,
                  Colors.black87,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 30,
                children: [
                  Icon(
                    Icons.video_camera_back_rounded,
                    size: 80,
                    color: Colors.white70,
                  ),
                  Text(
                    'Initializing Video-Editor...',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      color: Colors.white70,
                      strokeWidth: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
