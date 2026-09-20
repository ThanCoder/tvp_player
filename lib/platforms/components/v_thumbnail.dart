import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:tvp_player/core/models/v_file.dart';
import 'package:tvp_player/core/util/app_util.dart';
import 'package:tvp_player/core/util/platform_util.dart';

class VThumbnail extends StatelessWidget {
  const new({super.key, required this.file});
  final VFile file;

  @override
  Widget build(BuildContext context) {
    final cacheFile = File(
      AppUtil.instance.getPlatformCachePath('${file.name.onlyName}.jpg'),
    );
    if (cacheFile.existsSync()) {
      return Image.file(
        cacheFile,
        fit: .cover,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.image_not_supported_outlined, size: 50),
      );
    }
    return FutureBuilder(
      future: PlatformUtil.genThumbnail(file, cacheFile),
      builder: (context, snapshot) {
        if (snapshot.connectionState == .waiting) {
          return Center(child: CircularProgressIndicator.adaptive());
        }
        if (cacheFile.existsSync()) {
          return Image.file(
            cacheFile,
            fit: .cover,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.image_not_supported_outlined, size: 50),
          );
        }
        return Icon(Icons.image_not_supported_outlined, size: 50);
      },
    );
  }
}
