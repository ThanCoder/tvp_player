import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:tvp_player/core/controllers/i_controller.dart';
import 'package:tvp_player/core/controllers/v_file_controller.dart';
import 'package:tvp_player/core/models/v_file.dart';
import 'package:tvp_player/core/util/app_util.dart';
import 'package:tvp_player/core/util/platform_util.dart';
import 'package:tvp_player/funcs.dart';
import 'package:tvp_player/platforms/components/dialog/error_alert_dialog.dart';
import 'package:tvp_player/platforms/components/folder_grid_item.dart';
import 'package:tvp_player/platforms/components/list_view_style/list_view_style.dart';
import 'package:tvp_player/platforms/components/v_file_grid_item.dart';
import 'package:tvp_player/platforms/mobile/vf_selection_item.dart';
import 'package:tvp_player/platforms/pages/vfile_result_page.dart';
import 'package:tvp_player/routers.dart';

class MobileHomePage extends StatefulWidget {
  const new({super.key});

  @override
  State<MobileHomePage> createState() => _MobileHomePageState();
}

class _MobileHomePageState extends State<MobileHomePage> {
  @override
  void initState() {
    init();
    super.initState();
  }

  final con = ControllerManager.read<VFileController>();
  ColorScheme get col => Theme.of(context).colorScheme;

  Future<void> init() async {
    try {
      final res = await PlatformUtil.reqStoragePermission();
      if (!res) {
        return;
      }
      await con.loadFiles();
    } catch (e) {
      if (!mounted) return;
      showErrorDialog(context, e.toString());
    }
  }

  void moveMulti() async {
    final success = await showVFilesMoveDir(
      context,
      VfSelectionItem.pathsNotifer.value,
    );
    if (!success) return;
    VfSelectionItem.pathsNotifer.value = [];
    VfSelectionItem.selectionEnableNotifier.value = false;
  }

  void deleteMulti() async {
    final success = await showVFileDeleteMulti(
      context,
      VfSelectionItem.pathsNotifer.value,
    );
    if (!success) return;
    VfSelectionItem.pathsNotifer.value = [];
    VfSelectionItem.selectionEnableNotifier.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar(),
      body: StreamBuilder(
        stream: con.events.where((e) => e is Loading || e is Loaded),
        builder: (context, asyncSnapshot) {
          if (con.loading) {
            return Center(child: CircularProgressIndicator.adaptive());
          }
          final files = con.files;
          return RefreshIndicator.adaptive(
            onRefresh: init,
            child: CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [
                if (files.isEmpty) _emptyWidget(),
                if (files.isNotEmpty) SliverToBoxAdapter(child: _header),
                _selectActionBar(),
                _listWidget(files),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar _appbar() => AppBar(
    title: Text(AppUtil.instance.appName),
    actions: [
      StreamBuilder(
        stream: con.events.whereType<Loaded>(),
        builder: (context, asyncSnapshot) {
          return TSortProviderButton(
            value: con.sortItem,
            list: con.sortList,
            onApply: (item) {
              con.setSort(item);
            },
          );
        },
      ),
      SizedBox(width: 10),
      if (!AppUtil.instance.isMobileNotifier.value)
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: col.surfaceContainer,
            foregroundColor: col.onSurfaceVariant,
          ),
          onPressed: con.loadFiles,
          icon: Icon(Icons.refresh_outlined),
        ),
      if (!AppUtil.instance.isMobileNotifier.value) SizedBox(width: 10),
    ],
  );

  SliverFillRemaining _emptyWidget() {
    return SliverFillRemaining(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          decoration: BoxDecoration(
            color: col.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: col.outlineVariant.withValues(alpha: .3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.videocam_off_rounded,
                size: 42,
                color: col.onSurfaceVariant,
              ),

              const SizedBox(height: 12),

              Text(
                'No Video Files',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: col.onSurface,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Your audio library is empty.',
                style: TextStyle(fontSize: 12, color: col.onSurfaceVariant),
              ),

              const SizedBox(height: 16),

              RefreshButton(text: const Text('Scan Again'), onClicked: init),
            ],
          ),
        ),
      ),
    );
  }

  Widget get _header {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(children: [ListViewStyleButton()]),
    );
  }

  Widget _selectActionBar() {
    return ValueListenableBuilder(
      valueListenable: VfSelectionItem.selectionEnableNotifier,
      builder: (context, enable, child) {
        if (!enable) {
          return SliverToBoxAdapter();
        }
        return ValueListenableBuilder(
          valueListenable: VfSelectionItem.pathsNotifer,
          builder: (context, paths, child) {
            return SliverAppBar(
              snap: false,
              floating: true,
              pinned: true,
              actions: [
                SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: () {
                    paths.clear();
                    setState(() {
                      VfSelectionItem.selectionEnableNotifier.value = false;
                    });
                  },
                  icon: Icon(Icons.clear_outlined),
                  label: Text('${paths.length} Selected'),
                ),
                Spacer(),
                if (paths.isNotEmpty)
                  IconButton(
                    onPressed: moveMulti,
                    icon: Icon(Icons.drive_file_move),
                  ),
                if (paths.isNotEmpty) SizedBox(width: 10),
                if (paths.isNotEmpty)
                  IconButton(
                    onPressed: deleteMulti,
                    icon: Icon(Icons.delete_outline, color: Colors.red),
                  ),
              ],
              automaticallyImplyLeading: false,
            );
          },
        );
      },
    );
  }

  Widget _listWidget(List<VFile> files) {
    // folder
    return ValueListenableBuilder(
      valueListenable: ListViewStyleButton.current,
      builder: (context, listStyle, child) {
        if (listStyle == .folder) {
          return SliverPadding(
            padding: .all(10),
            sliver: SliverGrid.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 150,
                mainAxisExtent: 150,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
              ),
              itemCount: con.groups.length,
              itemBuilder: (context, index) {
                final group = con.groups.entries.elementAt(index);
                return GestureDetector(
                  onTap: () {
                    context.pushMaterialPageRoute(
                      builder: (mainCtx) => VfileResultPage(title: group.key),
                    );
                  },
                  child: FolderGridItem(title: group.key, files: group.value),
                );
              },
            ),
          );
        }
        return _allVideoListStyle(files);
      },
    );
  }

  SliverPadding _allVideoListStyle(List<VFile> files) {
    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverGrid.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240,
          crossAxisSpacing: 10,
          mainAxisSpacing: 16,
          childAspectRatio: 240 / 210,
        ),
        itemCount: files.length,
        itemBuilder: (context, index) => VfSelectionItem(
          file: files[index],
          child: VFileGridItem(
            file: files[index],
            onClicked: (file) {
              if (VfSelectionItem.selectionEnableNotifier.value) {
                VfSelectionItem.toggleCheck(file);
                return;
              }
              goVfPlayer(context, file);
            },
            onMenu: (file) {
              if (VfSelectionItem.selectionEnableNotifier.value) {
                return;
              }
              showVFileMenu(context, file);
            },
            onLongPress: () {
              VfSelectionItem.selectionEnableNotifier.value = true;
              VfSelectionItem.toggleCheck(files[index]);
            },
          ),
        ),
      ),
    );
  }
}
