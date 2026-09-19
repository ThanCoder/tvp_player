import 'dart:io';

import 'package:than_pkg_android/than_pkg_android.dart';
import 'package:than_pkg_linux/core/utils/path_ext.dart';
import 'package:than_pkg_linux/than_pkg_linux.dart';
import 'package:tvp_player/core/models/v_file.dart';

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
          ),
        );
      }
    }
    return files;
  }

  static Future<void> genThumbnail(VFile file, String savePath) async {
    if (Platform.isAndroid) {
      await ThanPkgAndroid.getInstance.videoHandler.saveThumbnail(
        file.path,
        savePath,
      );
    }
  }
}
