import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:tvp_player/core/models/v_file.dart';
import 'package:tvp_player/platforms/components/v_thumbnail.dart';

class VfFileInfoMenu extends StatelessWidget {
  const new({super.key, required this.file});

  final VFile file;

  @override
  Widget build(BuildContext context) {
    return TScrollableColumn(
      children: [
        _Header(file: file),

        const SizedBox(height: 20),

        _InfoSection(
          title: 'Video',
          children: [
            _InfoTile(
              icon: Icons.video_file_outlined,
              label: 'Name',
              value: file.name,
            ),
            _InfoTile(
              icon: Icons.sd_storage_outlined,
              label: 'Size',
              value: _formatSize(file.size),
            ),
            _InfoTile(
              icon: Icons.timer_outlined,
              label: 'Duration',
              value: _formatDuration(file.duration),
            ),
          ],
        ),

        const SizedBox(height: 20),

        _InfoSection(
          title: 'Dates',
          children: [
            _InfoTile(
              icon: Icons.add_circle_outline,
              label: 'Added',
              value: _formatDate(file.dateAdded),
            ),
            _InfoTile(
              icon: Icons.update_outlined,
              label: 'Modified',
              value: _formatDate(file.dateModified),
            ),
          ],
        ),

        const SizedBox(height: 20),

        _InfoSection(
          title: 'File',
          children: [
            _InfoTile(
              icon: Icons.folder_outlined,
              label: 'Path',
              value: file.path,
              multiline: true,
            ),
            _InfoTile(
              icon: Icons.fingerprint,
              label: 'ID',
              value: file.id,
              multiline: true,
            ),
          ],
        ),
      ],
    );
  }

  static String _formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }

    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  static String _formatDate(DateTime date) {
    final local = date.toLocal();

    return '${local.year}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.file});

  final VFile file;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: ClipRRect(
            borderRadius: .circular(14),
            child: VThumbnail(file: file),
          ),
          // Icon(
          //   Icons.movie_outlined,
          //   size: 32,
          //   color: theme.colorScheme.primary,
          // ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                file.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _VfFileInfoMenuState._formatSize(file.size),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.multiline = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 14),
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              maxLines: multiline ? 4 : 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VfFileInfoMenuState {
  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
