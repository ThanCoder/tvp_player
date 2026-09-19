import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:tvp_player/core/controllers/i_controller.dart';
import 'package:tvp_player/core/models/v_file.dart';
import 'package:tvp_player/core/util/platform_util.dart';

class Rename extends IControllerEvent {
  final VFile file;
  const Rename(this.file);
}

final durationSortItem = TSortItem(
  id: 2,
  title: 'Duration',
  isTrue: true,
  trueTitle: 'Shortest',
  falseTitle: 'Longest',
);

class VFileController extends IController {
  @override
  Future<void> init() async {}

  List<VFile> files = [];
  bool loading = false;
  final groups = <String, List<VFile>>{};
  TSortItem sortItem = .dateTSortItem;
  List<TSortItem> sortList = [
    .nameTSortItem,
    .dateTSortItem,
    .sizeTSortItem,
    durationSortItem,
  ];

  Future<void> loadFiles() async {
    loading = true;
    addEvent(Loading());
    files = await PlatformUtil.scanVideoFiles();
    sort();

    _loadGroups();

    loading = false;
    addEvent(Loaded());
  }

  void _loadGroups() {
    groups.clear();
    for (var f in files) {
      groups.putIfAbsent(f.path.pathBuf.parent.basename, () => []).add(f);
    }
  }

  void sort() {
    if (sortItem.id == TSortItem.dateTSortItem.id) {
      files.sortData(newest: sortItem.isTrue);
    }
    if (sortItem.id == TSortItem.nameTSortItem.id) {
      files.sortName(aToZ: sortItem.isTrue);
    }
    if (sortItem.id == TSortItem.sizeTSortItem.id) {
      files.sortSize(smallToBig: sortItem.isTrue);
    }
    if (sortItem.id == durationSortItem.id) {
      files.sortDuration(smallToBig: sortItem.isTrue);
    }
  }

  void setSort(TSortItem item) {
    sortItem = item;
    sort();
    _loadGroups();

    addEvent(Loaded());
  }

  VFile? getById(String id) {
    final index = files.indexWhere((e) => e.id == id);
    if (index == -1) return null;
    return files[index];
  }

  Future<void> rename(VFile file, String newName) async {
    try {
      final index = files.indexWhere((e) => e.path == file.path);
      if (index == -1) return;
      final newPath = file.path.pathBuf.parent.join(newName);
      final newFile = file.copyWith(name: newName, path: newPath.path);
      files[index] = newFile;
      _loadGroups();

      // change file
      await File(file.path).rename(newPath.path);

      addEvent(Rename(newFile));
      addEvent(Loaded());
    } catch (e) {
      addEvent(Error(e.toString()));
    }
  }

  Future<void> deleteMulti(List<VFile> delFiles) async {
    try {
      for (var f in delFiles) {
        await File(f.path).deleteSafe();
      }
      await loadFiles();
    } catch (e) {
      addEvent(Error(e.toString()));
    }
  }

  Future<void> moveMulti(List<String> paths, Directory newFolder) async {
    try {
      if (!newFolder.existsSync()) {
        newFolder.createSync(recursive: true);
      }

      for (var p in paths) {
        final newPath = newFolder.join(p.getName());
        await File(p).rename(newPath);
      }
      await loadFiles();
    } catch (e) {
      addEvent(Error(e.toString()));
    }
  }
}
