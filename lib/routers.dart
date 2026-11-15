import 'package:material_ui/material_ui.dart';
import 'package:tvp_player/ui/index.dart';
import 'package:tvp_player/core/models/v_file.dart';
import 'package:tvp_player/core/util/app_util.dart';
import 'package:tvp_player/platforms/pages/tv_player/tv_player_page.dart';
import 'package:tvp_player/platforms/pages/vf_player_desktop/vf_player_desktop_page.dart';

Future<void> goVfPlayer(
  BuildContext context,
  VFile file, {
  String? host,
}) async {
  if (AppUtil.instance.isMobileNotifier.value) {
    await context.pushMaterialPageRoute(
      builder: (mainCtx) => TvPlayerPage(file: file),
    );
    return;
  } else {
    await context.pushMaterialPageRoute(
      builder: (mainCtx) => VfPlayerDesktopPage(file: file, host: host),
    );
    return;
  }
  // showErrorDialog(context, 'Unsupported');
  // throw UnimplementedError('for desktop');
}
