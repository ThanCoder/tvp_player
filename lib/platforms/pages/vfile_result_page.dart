import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:tvp_player/core/controllers/i_controller.dart';
import 'package:tvp_player/core/controllers/v_file_controller.dart';
import 'package:tvp_player/core/models/v_file.dart';
import 'package:tvp_player/funcs.dart';
import 'package:tvp_player/platforms/components/v_file_grid_item.dart';
import 'package:tvp_player/routers.dart';

class VfileResultPage extends StatefulWidget {
  const new({super.key, required this.title});
  final String title;

  @override
  State<VfileResultPage> createState() => _VfileResultPageState();
}

class _VfileResultPageState extends State<VfileResultPage> {
  final con = ControllerManager.read<VFileController>();
  bool selectEnable = false;
  List<String> paths = [];

  void toggleCheck(VFile file) {
    if (paths.contains(file.path)) {
      paths.remove(file.path);
    } else {
      paths.add(file.path);
    }
    setState(() {});
  }

  void moveMulti() async {
    final success = await showVFilesMoveDir(context, paths);
    if (!success) return;
    paths.clear();
    setState(() {
      selectEnable = false;
    });
  }

  void deleteMulti() {}

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
          return RefreshIndicator(
            onRefresh: con.loadFiles,
            child: CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [
                if (selectEnable) _selectAction(),

                _allVideoListStyle(con.groups[widget.title] ?? []),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar _appbar() => AppBar(
    title: Text(widget.title),
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
    ],
  );

  SliverAppBar _selectAction() {
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
              selectEnable = false;
            });
          },
          icon: Icon(Icons.clear_outlined),
          label: Text('${paths.length} Selected'),
        ),
        Spacer(),
        if (paths.isNotEmpty)
          IconButton(onPressed: moveMulti, icon: Icon(Icons.drive_file_move)),
        if (paths.isNotEmpty) SizedBox(width: 10),
        if (paths.isNotEmpty)
          IconButton(
            onPressed: deleteMulti,
            icon: Icon(Icons.delete_outline, color: Colors.red),
          ),
      ],
      automaticallyImplyLeading: false,
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
        itemBuilder: (context, index) {
          final file = files[index];
          return Stack(
            children: [
              VFileGridItem(
                file: file,
                onClicked: (file) {
                  if (selectEnable) {
                    toggleCheck(file);
                    return;
                  }
                  goVfPlayer(context, file);
                },
                onLongPress: () {
                  toggleCheck(file);
                  setState(() {
                    selectEnable = true;
                  });
                },
                onMenu: selectEnable
                    ? null
                    : (file) {
                        showVFileMenu(context, file);
                      },
              ),
              if (selectEnable)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Checkbox.adaptive(
                    value: paths.contains(file.path),
                    onChanged: (value) {
                      toggleCheck(file);
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
