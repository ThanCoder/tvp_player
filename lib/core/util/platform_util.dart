import 'dart:io';
import 'dart:isolate';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:than_media_tag/core/av_format.dart';
import 'package:than_media_tag/models/media_info.dart';
import 'package:than_pkg_android/than_pkg_android.dart';
import 'package:than_pkg_linux/than_pkg_linux.dart';
import 'package:tvp_player/core/models/v_file.dart';
import 'package:tvp_player/keys.dart';

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
    if (Platform.isLinux) {
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

              final fmt = AvFormat();
              final fmtRes = fmt.open(f.path);
              if (fmtRes.isErr) {
                continue;
              }
              fmt.loadInfo();
              for (var stm in fmt.infoList) {
                if (stm is VideoStreamInfo) {
                  dur = stm.duration;
                  thumbnailExists = true;
                }
              }

              files.add(
                .new(
                  id: f.path,
                  name: f.name,
                  size: f.size,
                  path: f.path,
                  duration: dur,
                  dateAdded: f.changedDate,
                  dateModified: f.modifiedDate,
                  thumbnailExists: thumbnailExists,
                ),
              );
              if (fmtRes.isOk) {
                fmt.close();
              }
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
    if (saveFile.existsSync()) return;
    if (Platform.isAndroid) {
      await ThanPkgAndroid.getInstance.videoHandler.saveThumbnail(
        file.path,
        saveFile.path,
      );
    }
    if (Platform.isLinux) {
      // print('savePath: $savePath');
      // return;
      if (!file.thumbnailExists) return;
      try {
        final result = await Process.run('ffmpeg', [
          '-ss',
          (position.inMilliseconds / 1000).toString(),
          '-i',
          file.path,
          '-frames:v',
          '1',
          '-q:v',
          '2',
          '-y',
          saveFile.path,
        ]);

        if (result.exitCode != 0) {
          debugPrint(
            '[PlatformUtil:genThumbnail]: FFmpeg error: ${result.stderr}',
          );
        }
      } catch (e, st) {
        debugPrint('[PlatformUtil:genThumbnail]: $e\n$st');
      }
    }
  }
}
