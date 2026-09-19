import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:tvp_player/platforms/components/dialog/error_alert_dialog.dart';

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
    } catch (e) {
      showErrorDialog(context, e.toString());
    }
  }

  void onClicked(FileSystemEntity file) {
    if (file is! Directory) return;
    dir = file.directory;
    scan();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar(),
      body: RefreshIndicator.adaptive(
        onRefresh: scan,
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              floating: true,
              pinned: true,
              actions: [
                SizedBox(width: 10),
                if (canGoBack)
                  FilledButton.icon(onPressed: goBack, label: Text('Go Back')),
                if (canGoBack) Spacer(),
                FilledButton.icon(
                  onPressed: moveHere,
                  icon: Icon(Icons.gps_fixed),
                  label: Text('Move Here'),
                ),
                SizedBox(width: 10),
              ],
            ),

            _listWidget(),
          ],
        ),
      ),
    );
  }

  AppBar _appbar() {
    return AppBar(
      title: Text('File Exp'),
      actions: [
        Row(
          children: [
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
    return Row(
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
    );
  }

  Widget thumbnail(FileSystemEntity file) {
    if (file is Directory) {
      return Icon(Icons.folder_outlined, size: 80);
    }
    return Icon(Icons.file_present_outlined, size: 80);
  }
}
