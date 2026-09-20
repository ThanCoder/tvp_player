import 'package:dart_core_extensions/dart_core_extensions.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class VFile {
  VFile({
    required this.id,
    required this.name,
    required this.size,
    required this.path,
    required this.duration,
    required this.dateAdded,
    required this.dateModified,
    required this.thumbnailExists,
  });
  final String id;
  final String name;
  final int size;
  final String path;
  final Duration duration;
  final DateTime dateAdded;
  final DateTime dateModified;
  final bool thumbnailExists;

  VFile copyWith({
    String? id,
    String? name,
    int? size,
    String? path,
    Duration? duration,
    DateTime? dateAdded,
    DateTime? dateModified,
    bool? thumbnailExists,
  }) {
    return VFile(
      id: id ?? this.id,
      name: name ?? this.name,
      size: size ?? this.size,
      path: path ?? this.path,
      duration: duration ?? this.duration,
      dateAdded: dateAdded ?? this.dateAdded,
      dateModified: dateModified ?? this.dateModified,
      thumbnailExists: thumbnailExists ?? this.thumbnailExists,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'id': id,
      'size': size,
      'path': path,
      'duration': duration.inMilliseconds,
      'dateAdded': dateAdded.millisecondsSinceEpoch,
      'dateModified': dateModified.millisecondsSinceEpoch,
      'thumbnailExists': thumbnailExists,
    };
  }

  factory VFile.fromMap(Map<String, dynamic> map) {
    return VFile(
      id: map['id'] as String,
      name: map['name'] as String,
      size: map['size'] as int,
      path: map['path'] as String,
      duration: Duration(milliseconds: map.getInt(['duration'])),
      dateAdded: DateTime.fromMillisecondsSinceEpoch(map['dateAdded'] as int),
      dateModified: DateTime.fromMillisecondsSinceEpoch(
        map['dateModified'] as int,
      ),
      thumbnailExists: map.getBool(['thumbnailExists']),
    );
  }
}

extension VFileX on List<VFile> {
  void sortData({bool newest = true}) {
    sort((a, b) {
      if (newest) {
        return b.dateModified.compareTo(a.dateModified);
      } else {
        return a.dateModified.compareTo(b.dateModified);
      }
    });
  }

  void sortName({bool aToZ = true}) {
    sort((a, b) {
      if (aToZ) {
        return a.name.compareTo(b.name);
      } else {
        return b.name.compareTo(a.name);
      }
    });
  }

  void sortSize({bool smallToBig = true}) {
    sort((a, b) {
      if (smallToBig) {
        return a.size.compareTo(b.size);
      } else {
        return b.size.compareTo(a.size);
      }
    });
  }

  void sortDuration({bool smallToBig = true}) {
    sort((a, b) {
      if (smallToBig) {
        return a.duration.compareTo(b.duration);
      } else {
        return b.duration.compareTo(a.duration);
      }
    });
  }
}
