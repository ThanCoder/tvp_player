import 'package:material_ui/material_ui.dart';
import 'package:tvp_player/core/models/v_file.dart';

class FolderGridItem extends StatelessWidget {
  const new({super.key, required this.title, required this.files});
  final String title;
  final List<VFile> files;

  @override
  Widget build(BuildContext context) {
    final col = Theme.of(context).colorScheme;
    return Container(
      // padding: .all(2),
      decoration: BoxDecoration(
        borderRadius: .circular(15),
        color: col.surfaceContainer,
      ),
      child: Column(
        crossAxisAlignment: .center,
        children: [
          Icon(Icons.folder_outlined, size: 90, color: col.outlineVariant),
          Text(
            title,
            maxLines: 2,
            overflow: .ellipsis,
            style: TextStyle(fontWeight: .w600, color: col.onSurface),
          ),
          Expanded(
            child: Text(
              files.length.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: .w400,
                color: col.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
