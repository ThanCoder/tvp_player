import 'package:material_ui/material_ui.dart';
import 'package:tvp_player/core/util/app_util.dart';

class AppAboutDialogListTile extends StatelessWidget {
  const new({super.key, required this.descText, required this.iconAssetPath});
  final String descText;
  final String iconAssetPath;

  @override
  Widget build(BuildContext context) {
    final col = Theme.of(context).colorScheme;
    return ListTile(
      tileColor: col.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: .circular(15)),
      title: Text('App About'),
      onTap: () {
        final app = AppUtil.instance;
        showAboutDialog(
          context: context,

          applicationName: app.appName,
          applicationVersion: 'Version ${app.version}',

          applicationIcon: SizedBox(
            width: 50,
            height: 50,
            child: ClipRRect(
              borderRadius: .circular(12),
              child: Image.asset(iconAssetPath, fit: BoxFit.cover),
            ),
          ),

          applicationLegalese: '© 2026 Than Coder',

          children: [
            const SizedBox(height: 16),

            Text(descText),

            const SizedBox(height: 16),

            const Text('Built with Flutter.'),

            Text(
              'Developed by Than Coder',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 12),

            Text(
              '© 2026 Than Coder',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }
}
