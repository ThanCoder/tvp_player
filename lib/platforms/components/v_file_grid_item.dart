import 'package:flutter/material.dart';
import 'package:tvp_player/core/models/v_file.dart';
import 'package:tvp_player/platforms/components/v_thumbnail.dart';

class VFileGridItem extends StatelessWidget {
  const new({
    super.key,
    required this.file,
    this.onClicked,
    this.onMenu,
    this.onLongPress,
  });
  final VFile file;
  final void Function(VFile file)? onClicked;
  final void Function(VFile file)? onMenu;
  final void Function()? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onClicked?.call(file),
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: VThumbnail(file: file),
                ),

                Positioned(
                  right: 6,
                  bottom: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .75),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      _formatDuration(file.duration),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Text(
                  file.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              SizedBox(width: 10),
              if (onMenu != null)
                InkWell(
                  onTap: () => onMenu?.call(file),
                  child: Icon(Icons.more_vert_outlined),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
