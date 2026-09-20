import 'package:flutter/material.dart';
import 'package:tvp_player/core/controllers/i_controller.dart';
import 'package:tvp_player/core/controllers/v_file_controller.dart';
import 'package:tvp_player/core/models/v_file.dart';

class VfSelectionItem extends StatefulWidget {
  const new({super.key, required this.file, required this.child});
  final VFile file;
  final Widget child;

  static final selectionEnableNotifier = ValueNotifier<bool>(false);
  static final pathsNotifer = ValueNotifier<List<String>>([]);

  static void toggleCheck(VFile file) {
    final list = pathsNotifer.value.toList();

    if (list.contains(file.path)) {
      list.remove(file.path);
    } else {
      list.add(file.path);
    }
    pathsNotifer.value = list;
  }

  @override
  State<VfSelectionItem> createState() => _VfSelectionItemState();
}

class _VfSelectionItemState extends State<VfSelectionItem> {
  final con = ControllerManager.read<VFileController>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: VfSelectionItem.selectionEnableNotifier,
      builder: (context, enable, child) {
        if (enable) {
          return ValueListenableBuilder(
            valueListenable: VfSelectionItem.pathsNotifer,
            builder: (context, value, child) {
              return Stack(
                fit: .expand,
                children: [
                  widget.child,
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Checkbox.adaptive(
                      value: VfSelectionItem.pathsNotifer.value.contains(
                        widget.file.path,
                      ),
                      onChanged: (value) {
                        VfSelectionItem.toggleCheck(widget.file);
                      },
                    ),
                  ),
                ],
              );
            },
          );
        }
        return widget.child;
      },
    );
  }
}
