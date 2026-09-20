import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:tvp_player/core/controllers/i_controller.dart';
import 'package:tvp_player/core/controllers/v_file_controller.dart';
import 'package:tvp_player/core/models/v_file.dart';
import 'package:tvp_player/core/util/platform_util.dart';
import 'package:tvp_player/platforms/components/dialog/confirm_alert_dialog.dart';
import 'package:tvp_player/platforms/components/dialog/prompt_alert_dialog.dart';
import 'package:tvp_player/platforms/components/v_file_menu.dart';
import 'package:tvp_player/platforms/components/vf_file_info_menu.dart';
import 'package:tvp_player/platforms/pages/file_exproler/file_exp.dart';

Future<void> showVFileMenu(BuildContext context, VFile file) async {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => VFileMenu(file: file),
  );
}

Future<void> showVFileInfo(BuildContext context, VFile file) async {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => VfFileInfoMenu(file: file),
  );
}

Future<void> showVFileRename(BuildContext context, VFile file) async {
  final ext = file.name.extension;
  final name = await showPromptAlertDialog(
    context,
    file.name.onlyName,
    barrierDismissible: false,
    maxLines: null,
    confirmText: 'Rename',
  );
  if (name == null) return;
  final newName = '$name.$ext';
  final con = ControllerManager.read<VFileController>();
  await con.rename(file, newName);
}

// move
Future<bool> showVFilesMoveDir(BuildContext context, List<String> paths) async {
  final movePath = await context.pushMaterialPageRoute<String>(
    builder: (mainCtx) =>
        FileExp(rootDir: Directory(PlatformUtil.getRootDir())),
  );
  if (movePath == null) return false;
  final con = ControllerManager.read<VFileController>();
  await con.moveMulti(paths, Directory(movePath));
  return true;
}

Future<void> showVFileDelete(BuildContext context, VFile file) async {
  final col = Theme.of(context).colorScheme;

  final conf = await showConfirmDialog(
    context,
    'Want To Delete?\n`${file.name}\n${file.path}`',
    title: 'Delete!',
    closeText: 'No',
    confirmText: 'Delete Forever!',
    confirmColor: col.error,
    confirmForegroundColor: col.onError,
  );
  if (!conf) return;
  final con = ControllerManager.read<VFileController>();
  await con.deleteMulti([file.path]);
}

Future<bool> showVFileDeleteMulti(
  BuildContext context,
  List<String> paths,
) async {
  final col = Theme.of(context).colorScheme;

  final conf = await showConfirmDialog(
    context,
    'Want To Delete?\n${paths.map((e) => '`${e.getName()}`').join(',')}',
    title: 'Delete!',
    closeText: 'No',
    confirmText: 'Delete Forever!',
    confirmColor: col.error,
    confirmForegroundColor: col.onError,
  );
  if (!conf) return false;
  final con = ControllerManager.read<VFileController>();
  await con.deleteMulti(paths);
  return true;
}
