import 'package:flutter/material.dart';
import 'package:tvp_player/core/controllers/i_controller.dart';
import 'package:tvp_player/core/controllers/v_file_controller.dart';
import 'package:tvp_player/core/models/v_file.dart';
import 'package:tvp_player/funcs.dart';
import 'package:tvp_player/platforms/components/v_thumbnail.dart';

class VFileMenu extends StatefulWidget {
  const new({super.key, required this.file});

  final VFile file;

  @override
  State<VFileMenu> createState() => _VFileMenuState();
}

class _VFileMenuState extends State<VFileMenu> {
  final con = ControllerManager.read<VFileController>();

  void rename() async {
    showVFileRename(context, widget.file);
  }

  void delete() {
    showVFileDelete(context, widget.file);
  }

  void showInfo() {
    showVFileInfo(context, widget.file);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File info
            _info(theme, colorScheme),

            const Divider(height: 1),

            // Actions
            _MenuItem(
              icon: Icons.play_arrow_rounded,
              title: 'Play',
              onTap: () {
                Navigator.pop(context);
                // play video
              },
            ),

            // _MenuItem(
            //   icon: Icons.playlist_add_rounded,
            //   title: 'Add to playlist',
            //   onTap: () {
            //     Navigator.pop(context);
            //     // add to playlist
            //   },
            // ),
            _MenuItem(
              icon: Icons.edit_rounded,
              title: 'Rename',
              onTap: () {
                Navigator.pop(context);
                // rename
                rename();
              },
            ),

            _MenuItem(
              icon: Icons.info_outline_rounded,
              title: 'Details',
              onTap: () {
                Navigator.pop(context);
                // show details
                showInfo();
              },
            ),

            // _MenuItem(
            //   icon: Icons.share_rounded,
            //   title: 'Share',
            //   onTap: () {
            //     Navigator.pop(context);
            //     // share
            //   },
            // ),
            const Divider(height: 1),

            _MenuItem(
              icon: Icons.delete_outline_rounded,
              title: 'Delete',
              iconColor: colorScheme.error,
              textColor: colorScheme.error,
              onTap: () {
                Navigator.pop(context);
                // delete
                delete();
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Padding _info(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: VThumbnail(file: widget.file),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.file.name,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _fileInfo(widget.file),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fileInfo(VFile file) {
    final duration = _formatDuration(file.duration);
    final size = _formatSize(file.size);

    return '$duration • $size';
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

  String _formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }

    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor)),
      onTap: onTap,
    );
  }
}

Future<void> showVFileMenu(BuildContext context, VFile file) async {
  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return VFileMenu(file: file);
    },
  );
}
