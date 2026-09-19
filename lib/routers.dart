import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:tvp_player/core/models/v_file.dart';
import 'package:tvp_player/platforms/pages/tv_player/tv_player_page.dart';

Future<void> goVfPlayer(BuildContext context, VFile file) async {
  await context.pushMaterialPageRoute(
    builder: (mainCtx) => TvPlayerPage(file: file),
  );
}
