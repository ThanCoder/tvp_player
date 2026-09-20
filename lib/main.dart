import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:than_pkg_linux/than_pkg_linux.dart';
import 'package:tvp_player/core/controllers/i_controller.dart';
import 'package:tvp_player/core/controllers/v_file_controller.dart';
import 'package:tvp_player/core/util/app_util.dart';
import 'package:tvp_player/keys.dart';
import 'package:tvp_player/platforms/platform_app.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppUtil.instance.init();

  if (Platform.isLinux) {
    final cf = AppUtil.instance.config;
    ThanPkgLinux.getInstance.window.setWindowSize(
      width: cf.getDouble(appWindowWidthKey,600).toInt(),
      height: cf.getDouble(appWindowHeightKey,400).toInt(),
    );
  }

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
