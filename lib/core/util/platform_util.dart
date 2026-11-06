import 'dart:io';
import 'dart:isolate';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:mediatag_bin/mediatag_bin.dart';
import 'package:than_pkg_android/than_pkg_android.dart';
import 'package:than_pkg_linux/than_pkg_linux.dart';
import 'package:tvp_player/core/models/v_file.dart';
import 'package:tvp_player/keys.dart';
import 'package:uuid/v4.dart';

class PlatformUtil {
  static Future<void> launchUrl(String url) async {
    if (Platform.isLinux) {
      await ThanPkgLinux.getInstance.launcher.launchUrl(url);
      return;
    }
    if (Platform.isAndroid) {
      await ThanPkgAndroid.getInstance.launchHandler.launchUrl(url);
      return;
    }
  }

  static Future<String> getOutPath(String name) async {
    if (Platform.isLinux) {
      final p = await ThanPkgLinux.getInstance.pathHandler
          .getDownloadsDirectory();
      return p!.join(name);
    }
    if (Platform.isAndroid) {
      return ThanPkgAndroid.getInstance.pathHandler.getDownloadPath().join(
        name,
      );
    }

    throw UnsupportedError('Only Supported -> `android`,`linux`');
  }

  static String getRootDir() {
    if (Platform.isLinux) {
      return Platform.environment['HOME'] ?? '';
    }
    return ThanPkgAndroid.getInstance.pathHandler.getDeviceStoragePath();
  }

  static Future<bool> reqStoragePermission() async {
    if (Platform.isAndroid) {
      final pkg = ThanPkgAndroid.getInstance.storagePermissionHandler;
      if (!await pkg.isStoragePermissionGranted()) {
        await pkg.requestStoragePermission();
        return false;
      }
    }
    return true;
  }

  static Future<List<VFile>> scanVideoFiles() async {
    final List<VFile> files = [];
    if (Platform.isLinux || Platform.isWindows) {
      final pkg = MediatagBin.instance;
      final home = Platform.environment['HOME']!;
      final roots = <String>[
        home.join('Documents'),
        home.join('Downloads'),
        home.join('Videos'),
        home.join('Music'),
      ];
      return Isolate.run(() {
        final List<VFile> files = [];
        final scanFolder = roots.map((e) => Directory(e)).toList();
        while (scanFolder.isNotEmpty) {
          final dir = scanFolder.removeLast();
          for (var f in dir.listSync()) {
            if (videoExts.contains(f.extName)) {
              Duration dur = .new();
              bool thumbnailExists = false;

              try {
                final info = pkg.ffprobe.getFileInfoOrNullSync(f.path);
                if (info != null && info.formatOrNull != null) {
                  dur = info.formatOrNull!.duration;
                  thumbnailExists = true;
                }
              } catch (e) {
                debugPrint(
                  '[PlatformUtil:scanVideoFiles]: $e -> name:${f.name}',
                );
              }

              files.add(
                .new(
                  id: UuidV4().generate(),
                  name: f.name,
                  size: f.size,
                  path: f.path,
                  duration: dur,
                  dateAdded: f.changedDate,
                  dateModified: f.modifiedDate,
                  thumbnailExists: thumbnailExists,
                ),
              );
            }
            if (f is Directory) {
              scanFolder.add(f.directory);
            }
          }
        }
        return files;
      });
    }
    if (Platform.isAndroid) {
      final list = await ThanPkgAndroid.getInstance.mediaSelector.fetchVideos();
      for (var f in list) {
        files.add(
          .new(
            id: f.id.toString(),
            name: f.name,
            size: f.size,
            path: f.path,
            duration: f.duration,
            dateAdded: f.dateAdded,
            dateModified: f.dateModified,
            thumbnailExists: true,
          ),
        );
      }
    }
    return files;
  }

  static Future<void> genThumbnail(
    VFile file,
    File saveFile, {
    Duration position = const Duration(seconds: 1),
  }) async {
    if (await saveFile.exists()) return;
    if (Platform.isAndroid) {
      await ThanPkgAndroid.getInstance.videoHandler.saveThumbnail(
        file.path,
        saveFile.path,
      );
    }
    if (MediatagBin.instance.isSupported) {
      // print('savePath: $savePath');
      // return;
      if (!file.thumbnailExists) return;
      await MediatagBin.instance.ffmpeg.video.genThumbnail(
        file.path,
        saveFile.path,
      );
    }
  }
}
