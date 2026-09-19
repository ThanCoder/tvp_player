import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:tvp_player/core/controllers/i_controller.dart';
import 'package:tvp_player/core/controllers/v_file_controller.dart';
import 'package:tvp_player/core/util/app_util.dart';
import 'package:tvp_player/platforms/platform_app.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';

// import 'package:video_player_media_kit/video_player_media_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppUtil.instance.init();

  VideoPlayerMediaKit.ensureInitialized(
    android: true,
    iOS: true,
    macOS: true,
    windows: true,
    linux: true,
  );

  if (Platform.isAndroid) {
    final session = await AudioSession.instance;
    // await session.configure(AudioSessionConfiguration.music());
    await session.setActive(true);
  }

  ControllerManager.register(VFileController());
  ControllerManager.initAll();

  runApp(const PlatformApp());
}
