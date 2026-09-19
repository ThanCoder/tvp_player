// ignore_for_file: experimental_member_use

import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:than_pkg_android/than_pkg_android.dart';

import 'package:tvp_player/core/models/v_file.dart';
import 'package:tvp_player/core/util/app_util.dart';
import 'package:tvp_player/keys.dart';
import 'package:tvp_player/platforms/pages/tv_player/tv_gesture_indicator.dart';
import 'package:tvp_player/platforms/pages/tv_player/tv_player_controls.dart';

class TvPlayerPage extends StatefulWidget {
  const TvPlayerPage({super.key, required this.file});

  final VFile file;

  @override
  State<TvPlayerPage> createState() => _TvPlayerPageState();
}

class _TvPlayerPageState extends State<TvPlayerPage> {
  late final Player player;
  late final VideoController controller;

  Timer? _hideTimer;
  Timer? _gestureTimer;

  bool _showControls = true;

  // ---------------------------------------------------------------------------
  // Gesture
  // ---------------------------------------------------------------------------

  GestureType? _gestureType;

  double _gestureStartValue = 0;
  double _gestureValue = 0;

  // ignore: unused_field
  Offset? _gestureStartPosition;

  bool _showGestureIndicator = false;
  final config = AppUtil.instance.config;

  @override
  void initState() {
    if (Platform.isAndroid) {
      ThanPkgAndroid.getInstance.flutterUtils.toggleFullscreen(true);
    }
    super.initState();
    init();
  }

  StreamSubscription? _headphonesSession;
  StreamSubscription? _bluetoothSession;

  Future<void> init() async {
    final lastPos = config.getInt('$tvPlayerLastPosKey-${widget.file.id}');
    player = Player();
    controller = VideoController(player);

    // audio session
    if (Platform.isAndroid) {
      final session = await AudioSession.instance;
      _headphonesSession = session.becomingNoisyEventStream.listen((_) {
        // The user unplugged the headphones, so we should pause or lower the volume.
        player.pause();
      });

      _bluetoothSession = session.devicesChangedEventStream.listen((event) {
        for (var deviceRemoved in event.devicesRemoved) {
          // bluetooth
          if (deviceRemoved.type == .bluetoothA2dp ||
              deviceRemoved.type == .bluetoothLe ||
              deviceRemoved.type == .bluetoothSco) {
            player.pause();
          }
        }
      });
    }

    await player.open(Media(widget.file.path), play: lastPos == 0);
    await controller.waitUntilFirstFrameRendered;

    // _enterLandscape();
    _autoLandscape();

    _startHideTimer();

    if (lastPos > 0) {
      await Future.delayed(Duration(milliseconds: 1200));
      await player.seek(Duration(seconds: lastPos));
      await player.play();
    }
  }

  void _autoLandscape() async {
    final width = player.state.videoParams.w;
    final height = player.state.videoParams.h;

    if (width != null && height != null) {
      if (height > width) {
        // Portrait video
        if (Platform.isAndroid) {
          await ThanPkgAndroid.getInstance.orientationHandler.setOrientation(
            .SCREEN_ORIENTATION_SENSOR_PORTRAIT,
          );
        }
      } else {
        // Landscape video
        if (Platform.isAndroid) {
          await ThanPkgAndroid.getInstance.orientationHandler.setOrientation(
            .SCREEN_ORIENTATION_SENSOR_LANDSCAPE,
          );
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Landscape / Immersive
  // ---------------------------------------------------------------------------

  // Future<void> _enterLandscape() async {
  //   await ThanPkgAndroid.getInstance.orientationHandler.setOrientation(
  //     .SCREEN_ORIENTATION_SENSOR_LANDSCAPE,
  //   );
  // }

  Future<void> _exitLandscape() async {
    if (Platform.isAndroid) {
      await ThanPkgAndroid.getInstance.orientationHandler.setOrientation(
        .SCREEN_ORIENTATION_PORTRAIT,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _hideTimer?.cancel();
    _gestureTimer?.cancel();
    if (Platform.isAndroid) {
      ThanPkgAndroid.getInstance.flutterUtils.toggleFullscreen(false);
      ThanPkgAndroid.getInstance.brightnessHandler.restoreScreenBrightness();
    }
    _exitLandscape();
    if (player.state.position.inSeconds < player.state.duration.inSeconds) {
      config.putAndWriteAll(
        '$tvPlayerLastPosKey-${widget.file.id}',
        player.state.position.inSeconds,
      );
    }
    _bluetoothSession?.cancel();
    _headphonesSession?.cancel();

    player.dispose();

    super.dispose();
  }

  // ===========================================================================
  // CONTROLS
  // ===========================================================================

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();

    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      setState(() {
        _showControls = false;
      });
    });
  }

  // ===========================================================================
  // PLAY
  // ===========================================================================

  Future<void> _togglePlay() async {
    await player.playOrPause();

    _startHideTimer();
  }

  // ===========================================================================
  // SEEK
  // ===========================================================================

  Future<void> _seekRelative(Duration offset) async {
    var position = player.state.position + offset;

    final duration = player.state.duration;

    if (position < Duration.zero) {
      position = Duration.zero;
    }

    if (position > duration) {
      position = duration;
    }

    await player.seek(position);

    _startHideTimer();
  }

  // ===========================================================================
  // GESTURE START
  // ===========================================================================

  Future<void> _onVerticalDragStart(DragStartDetails details) async {
    final width = MediaQuery.sizeOf(context).width;
    final x = details.localPosition.dx;

    _gestureStartPosition = details.localPosition;

    // -------------------------------------------------------------------------
    // LEFT 40% = BRIGHTNESS
    // RIGHT 40% = VOLUME
    // MIDDLE 20% = NOTHING
    // -------------------------------------------------------------------------

    if (x < width * .40) {
      _gestureType = GestureType.brightness;

      // Android ရဲ့ လက်ရှိ brightness ကို အရင်ဖတ်
      _gestureStartValue = await _getBrightness();

      // Gesture start နေရာမှာ value မပြောင်းသွားအောင်
      // async ပြန်လာချိန်မှာ gesture က ပြောင်းပြီးသားလား စစ်
      if (!mounted || _gestureType != GestureType.brightness) {
        return;
      }

      _gestureValue = _gestureStartValue;
    } else if (x > width * .60) {
      _gestureType = GestureType.volume;

      _gestureStartValue = player.state.volume;
      _gestureValue = _gestureStartValue;
    } else {
      _gestureType = null;
      return;
    }

    _showGesture();
  }

  // ===========================================================================
  // GESTURE UPDATE
  // ===========================================================================

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final type = _gestureType;

    if (type == null) return;

    final screenHeight = MediaQuery.sizeOf(context).height;

    // -------------------------------------------------------------------------
    // UP = increase
    // DOWN = decrease
    //
    // 1 screen height = 100%
    // -------------------------------------------------------------------------

    final delta = -details.delta.dy / screenHeight;

    if (type == GestureType.brightness) {
      _updateBrightness(delta);
    } else {
      _updateVolume(delta);
    }

    _showGesture();
  }

  // ===========================================================================
  // GESTURE END
  // ===========================================================================

  void _onVerticalDragEnd(DragEndDetails details) {
    _gestureType = null;
    _gestureStartPosition = null;

    _gestureTimer?.cancel();

    _gestureTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      setState(() {
        _showGestureIndicator = false;
      });
    });

    _startHideTimer();
  }

  // ===========================================================================
  // BRIGHTNESS
  // ===========================================================================

  Future<double> _getBrightness() async {
    // Android brightness handler ကို 0.0 - 1.0 range လို့ယူထားတယ်။
    //
    // သင့် ThanPkgAndroid implementation က
    // 0 - 100 range ဖြစ်ရင် ဒီနေရာမှာ / 100 ပြောင်းပါ။
    final res = await ThanPkgAndroid.getInstance.brightnessHandler
        .getScreenBrightness();

    return res ?? 0.5;
  }

  void _updateBrightness(double delta) {
    final current = _gestureValue;

    final next = (current + delta).clamp(0.0, 1.0);

    _gestureValue = next;

    ThanPkgAndroid.getInstance.brightnessHandler.setScreenBrightness(next);

    _showGesture();
  }

  // ===========================================================================
  // VOLUME
  // ===========================================================================

  void _updateVolume(double delta) {
    // media_kit volume = 0.0 ~ 100.0

    final current = _gestureValue;

    final next = (current + (delta * 100)).clamp(0.0, 200.0);

    _gestureValue = next;

    player.setVolume(next);

    _showGesture();
  }

  // ===========================================================================
  // GESTURE INDICATOR
  // ===========================================================================

  void _showGesture() {
    if (!mounted) return;

    _gestureTimer?.cancel();

    setState(() {
      _showGestureIndicator = true;
    });
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // =================================================================
            // VIDEO
            // =================================================================

            Video(controller: controller, controls: NoVideoControls),

            // =================================================================
            // GESTURE LAYER
            // =================================================================
            GestureDetector(
              behavior: HitTestBehavior.translucent,

              onTap: _toggleControls,

              onDoubleTapDown: (details) {
                final width = MediaQuery.sizeOf(context).width;

                if (details.localPosition.dx < width / 2) {
                  _seekRelative(const Duration(seconds: -10));
                } else {
                  _seekRelative(const Duration(seconds: 10));
                }
              },

              onVerticalDragStart: _onVerticalDragStart,

              onVerticalDragUpdate: _onVerticalDragUpdate,

              onVerticalDragEnd: _onVerticalDragEnd,

              child: const SizedBox.expand(),
            ),

            // =================================================================
            // BRIGHTNESS / VOLUME INDICATOR
            // =================================================================
            if (_showGestureIndicator)
              Center(
                child: TvGestureIndicator(
                  type: _gestureType,
                  value: _gestureValue,
                ),
              ),

            // =================================================================
            // PLAYER CONTROLS
            // =================================================================
            IgnorePointer(
              ignoring: !_showControls || _gestureType != null,
              child: AnimatedOpacity(
                opacity: _showControls && _gestureType == null ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: TvPlayerControls(
                  file: widget.file,
                  player: player,
                  onBack: () {
                    Navigator.of(context).pop();
                  },
                  onPlayPause: _togglePlay,
                  onSeekBack: () {
                    _seekRelative(const Duration(seconds: -10));
                  },
                  onSeekForward: () {
                    _seekRelative(const Duration(seconds: 10));
                  },
                  onInteraction: _startHideTimer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
