import 'package:flutter/material.dart';
import 'package:tvp_player/core/util/app_util.dart';
import 'package:tvp_player/keys.dart';

enum ListViewStyle {
  all,
  folder;

  String get lable {
    return switch (this) {
      all => 'All',
      folder => 'Folder',
    };
  }

  IconData get iconData {
    return switch (this) {
      all => Icons.video_file_outlined,
      folder => Icons.folder_outlined,
    };
  }

  static ListViewStyle fromValue(String val) {
    return values.firstWhere((e) => e.name == val, orElse: () => .folder);
  }
}

class ListViewStyleButton extends StatefulWidget {
  const new({super.key});

  @override
  State<ListViewStyleButton> createState() => _ListViewStyleButtonState();

  static final current = ValueNotifier<ListViewStyle>(
    .fromValue(AppUtil.instance.config.getString(vfListViewStyleKey)),
  );
  static void save() {
    AppUtil.instance.config.putAndWriteAll(
      vfListViewStyleKey,
      current.value.name,
    );
  }
}

class _ListViewStyleButtonState extends State<ListViewStyleButton> {
  final items = ListViewStyle.values
      .map(
        (e) => DropdownMenuItem(
          value: e,
          child: Row(spacing: 10, children: [Icon(e.iconData), Text(e.lable)]),
        ),
      )
      .toList();
  @override
  Widget build(BuildContext context) {
    final col = Theme.of(context).colorScheme;
    return ValueListenableBuilder(
      valueListenable: ListViewStyleButton.current,
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            color: col.surfaceContainerHigh,
            borderRadius: .circular(15),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              borderRadius: .circular(15),
              padding: .symmetric(vertical: 5, horizontal: 8),
              value: value,
              items: items,
              onChanged: (val) {
                ListViewStyleButton.current.value = val!;
                ListViewStyleButton.save();
              },
            ),
          ),
        );
      },
    );
  }
}
