import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:tvp_player/core/util/app_util.dart';
import 'package:tvp_player/platforms/pages/cache_manager.dart';

import 'share_server/server_home_page.dart';
import 'version_manager.dart';

class MorePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final col = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text("More")),
      body: TScrollableColumn(
        children: [
          TMaterialThemeProviderChooser(),
          VersionManager(githubUrl: 'https://github.com/ThanCoder/tvp_player'),
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
        ],
      ),
    );
  }
}
