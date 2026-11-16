import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tvp_player/core/models/v_file.dart';
import 'package:tvp_player/platforms/mobile/mobile_home_page.dart';
import 'package:tvp_player/platforms/pages/more/more_page.dart';
import 'package:tvp_player/platforms/pages/vf_search_page.dart';
import 'package:tvp_player/routers.dart';
import 'package:tvp_player/ui/dialog/error_alert_dialog.dart';

class DesktopHomeScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<DesktopHomeScreen> createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends State<DesktopHomeScreen> {
  int index = 0;

  Future<void> _onDropFile(DropDetails details) async {
    try {
      final items = details.items;
      if (items.isEmpty) return;
      final f = items.first as DropFileItem;
      await goVfPlayer(context, VFile.createFile(File(f.localPath!)));
      if (!mounted) return;
    } catch (e) {
      showErrorDialog(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DropTarget(
        acceptedKinds: const {.file},
        onDrop: _onDropFile,
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: index,
              onDestinationSelected: (value) {
                setState(() {
                  index = value;
                });
              },
              destinations: [
                .new(icon: Icon(Icons.home_outlined), label: Text('Home')),
                .new(icon: Icon(Icons.search_outlined), label: Text('Search')),
                .new(icon: Icon(Icons.grid_view_outlined), label: Text('More')),
              ],
            ),
            VerticalDivider(),
            Expanded(
              child: IndexedStack(
                index: index,
                children: [MobileHomePage(), VfSearchPage(), MorePage()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
