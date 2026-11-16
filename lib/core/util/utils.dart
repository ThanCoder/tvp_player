import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

String generateIdFromFilePath(String filePath) {
  final file = File(filePath);

  if (!file.existsSync()) {
    return sha1.convert(utf8.encode(filePath)).toString();
  }

  final size = file.lengthSync();
  const readLen = 6;

  if (size <= readLen) {
    return sha1.convert(file.readAsBytesSync()).toString();
  }

  final fp = file.openSync(mode: FileMode.read);

  try {
    final data = <int>[];

    // First 2 bytes
    fp.setPositionSync(0);
    data.addAll(fp.readSync(2));

    // Middle 2 bytes
    fp.setPositionSync((size ~/ 2) - 1);
    data.addAll(fp.readSync(2));

    // Last 2 bytes
    fp.setPositionSync(size - 2);
    data.addAll(fp.readSync(2));

    return sha1.convert(data).toString();
  } finally {
    fp.closeSync();
  }
}
