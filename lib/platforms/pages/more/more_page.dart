import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:tvp_player/platforms/pages/more/create_linux_desktop_icon.dart';
import 'package:tvp_player/ui/index.dart';
import 'package:tvp_player/core/util/app_util.dart';
import 'package:tvp_player/platforms/pages/more/cache_manager.dart';
import 'package:tvp_player/platforms/pages/dev_pages/dev_route_tile.dart';

import '../share_server/server_home_page.dart';
import 'app_about_dialog.dart';
import 'version_manager.dart';

class MorePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final col = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text("More")),
      body: ScrollableColumn(
        children: [
          MaterialThemeProviderChooser(),
          VersionManager(githubUrl: 'https://github.com/ThanCoder/tvp_player'),
          if (AppUtil.instance.platformCacheExists)
            CacheManagerListTile(
              cacheDirPath: AppUtil.instance.getPlatformCachePath(),
            ),
          ListTile(
            tileColor: col.surfaceContainer,
            shape: RoundedRectangleBorder(borderRadius: .circular(15)),
            leading: Icon(Icons.share_outlined),
            trailing: Icon(Icons.arrow_forward_ios),
            title: Text('Share Server'),
            onTap: () {
              context.pushMaterialPageRoute(
                builder: (mainCtx) => ServerHomePage(),
              );
            },
          ),
          if (Platform.isLinux) CreateLinuxDesktopIcon(),
          DevRouteTile(),
          AppAboutDialogListTile(
            descText: 'Video Player Application.',
            iconAssetPath: 'assets/logo/logo1.png',
          ),
        ],
      ),
    );
  }
}
