import 'package:flutter/material.dart';
import 'package:tvp_player/core/models/v_file.dart';

class ShareGridItem extends StatelessWidget {
  const ShareGridItem({
    super.key,
    required this.file,
    required this.host,
    required this.onClicked,
  });
  final VFile file;
  final String host;
  final void Function(VFile file) onClicked;

  @override
  Widget build(BuildContext context) {
    final col = Theme.of(context).colorScheme;
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      borderRadius: .circular(15),
      onTap: () {
        onClicked(file);
      },
      child: Container(
        padding: .all(8),
        decoration: BoxDecoration(borderRadius: .circular(15)),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: .circular(5),
                child: Image.network(
                  'http://$host/api/thumbnail/${file.id}',
                  fit: .cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(Icons.image_not_supported_outlined, size: 80),
                  ),
                ),
              ),
            ),
            Positioned(left: 0, right: 0, bottom: 0, child: _content(col)),
          ],
        ),
      ),
    );
  }

  Widget _content(ColorScheme col) {
    return Container(
      padding: .symmetric(vertical: 5, horizontal: 8),
      decoration: BoxDecoration(
        color: col.surfaceContainer.withValues(alpha: .65),
      ),
      child: Text(
        file.name,
        maxLines: 2,
        overflow: .ellipsis,
        textAlign: .center,
        style: TextStyle(color: col.onSurface, fontSize: 14, fontWeight: .w600),
      ),
    );
  }
}
