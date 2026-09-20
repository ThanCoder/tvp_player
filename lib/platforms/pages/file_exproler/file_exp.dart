import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:tvp_player/core/util/app_util.dart';
import 'package:tvp_player/platforms/components/dialog/error_alert_dialog.dart';
import 'package:tvp_player/platforms/components/dialog/prompt_alert_dialog.dart';

class FileExp extends StatefulWidget {
  const new({super.key, required this.rootDir});
  final Directory rootDir;

  @override
  State<FileExp> createState() => _FileExpState();
}

class _FileExpState extends State<FileExp> {
  @override
  void initState() {
    dir = widget.rootDir;
    scan();
    super.initState();
  }

  late Directory dir;
  List<FileSystemEntity> files = [];
  bool showHidden = false;

  Future<void> scan() async {
    try {
      files.clear();
      if (showHidden) {
        final res = dir.listSync();
        files.addAll(res);
        setState(() {});
      } else {
        final res = dir.listSync();
        for (var f in res) {
          if (f.name.startsWith('.')) continue;
          files.add(f);
        }
        setState(() {});
      }
      files.sort((a, b) => a.name.compareTo(b.name));

      files.sort((a, b) {
        if (a is Directory && b is File) return -1;
        if (b is Directory && a is File) return 1;
        return 0;
      });
    } catch (e) {
      showErrorDialog(context, e.toString());
    }
  }

  void onClicked(FileSystemEntity file) {
    if (file is! Directory) return;
    dir = file.directory;
    scan();
  }

  void createFolder() async {
    final name = await showPromptAlertDialog(
      context,
      'New Folder',
      confirmText: 'New',
      onErrorCheck: (text) {
        if (text.isEmpty) return 'text required!';
        if (files.any((e) => e.name == text)) {
          return 'already exists!';
        }
        return null;
      },
    );
    if (name == null) return;
    try {
      final newFolder = Directory(dir.join(name));
      if (!newFolder.existsSync()) {
        await newFolder.create(recursive: true);
      }
      await scan();
    } catch (e) {
      if (!mounted) return;
      showErrorDialog(context, e.toString());
    }
  }

  bool get canGoBack {
    if (widget.rootDir.path == dir.path) return false;
    return true;
  }

  void goBack() {
    dir = dir.parent;
    scan();
  }

  void moveHere() {
    context.pop<String>(dir.path);
  }

  ColorScheme get col => Theme.of(context).colorScheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar(),
      body: Stack(
        fit: .expand,
        children: [
          RefreshIndicator.adaptive(
            onRefresh: scan,
            child: CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [
                if (canGoBack)
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    floating: true,
                    pinned: true,
                    actions: [
                      SizedBox(width: 10),
                      if (canGoBack)
                        FilledButton.icon(
                          onPressed: goBack,
                          label: Text('Go Back'),
                          icon: Icon(Icons.arrow_back_ios_new_outlined),
                        ),

                      Spacer(),
                    ],
                  ),

                _listWidget(),

                SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
          Positioned(bottom: 0, left: 0, right: 0, child: _bottomBar()),
        ],
      ),
    );
  }

  Container _bottomBar() {
    return Container(
      padding: .symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: col.surfaceContainer,
        borderRadius: .circular(12),
      ),
      child: Row(
        children: [
          FilledButton(onPressed: createFolder, child: Text('Create Folder')),
          Spacer(),
          FilledButton.icon(
            onPressed: moveHere,
            icon: Icon(Icons.gps_fixed),
            label: Text('Move Here'),
          ),
        ],
      ),
    );
  }

  AppBar _appbar() {
    return AppBar(
      title: Text('File Exp'),
      actions: [
        Row(
          children: [
            if (!AppUtil.instance.isMobileNotifier.value)
              IconButton(onPressed: scan, icon: Icon(Icons.refresh)),
            Text('Hidden File'),
            Checkbox.adaptive(
              value: showHidden,
              onChanged: (value) {
                setState(() {
                  showHidden = !showHidden;
                });
                scan();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _listWidget() {
    return StreamBuilder(
      stream: dir.list(),
      builder: (context, asyncSnapshot) {
        return SliverPadding(
          padding: .symmetric(vertical: 10, horizontal: 10),
          sliver: SliverList.separated(
            separatorBuilder: (context, index) => SizedBox(height: 10),
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              return InkWell(
                onTap: () => onClicked(file),
                child: listItem(file),
              );
            },
          ),
        );
      },
    );
  }

  Widget listItem(FileSystemEntity file) {
    return Container(
      decoration: BoxDecoration(
        color: col.surfaceContainer.withValues(alpha: .45),
        borderRadius: .circular(15),
      ),
      child: Row(
        children: [
          thumbnail(file),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              spacing: 4,
              children: [
                Text(file.name, maxLines: 2, overflow: .ellipsis),
                if (file is File)
                  Text('Size: ${FileSizeLabelExtension(file).fileSizeLabel()}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget thumbnail(FileSystemEntity file) {
    if (file is Directory) {
      return Icon(Icons.folder_outlined, size: 80);
    }
    return Icon(Icons.file_present_outlined, size: 80);
  }
}
