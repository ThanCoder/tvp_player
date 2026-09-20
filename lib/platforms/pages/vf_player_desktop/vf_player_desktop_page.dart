import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:tvp_player/core/models/v_file.dart';
import 'package:tvp_player/core/util/app_util.dart';
import 'package:tvp_player/keys.dart';

class VfPlayerDesktopPage extends StatefulWidget {
  const new({super.key, required this.file});
  final VFile file;

  @override
  State<VfPlayerDesktopPage> createState() => _VfPlayerDesktopPageState();
}

class _VfPlayerDesktopPageState extends State<VfPlayerDesktopPage> {
  @override
  void initState() {
    super.initState();
    init();
  }

  final Player player = .new();
  late final VideoController controller = .new(player);
  final config = AppUtil.instance.config;

  Future<void> init() async {
    final lastPos = config.getInt('$tvPlayerLastPosKey-${widget.file.id}');

    await player.open(Media(widget.file.path), play: lastPos == 0);
    await controller.waitUntilFirstFrameRendered;

    if (lastPos > 0) {
      await Future.delayed(Duration(milliseconds: 1200));
      await player.seek(Duration(seconds: lastPos));
      await player.play();
    }
  }

  void existsPlayer() async {
    if (player.state.position.inSeconds < player.state.duration.inSeconds) {
      config.putAndWriteAll(
        '$tvPlayerLastPosKey-${widget.file.id}',
        player.state.position.inSeconds,
      );
    }
    if (player.state.playing) {
      await player.stop();
    }
    await player.dispose();
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: existsPlayer,
            icon: Icon(Icons.arrow_back_ios_new_outlined),
          ),
        ),
        body: Video(controller: controller),
      ),
    );
  }
}
