import 'package:flutter/widgets.dart';
import 'package:tvp_player/ui/build_context_x.dart';

class EmptyCard extends StatelessWidget {
  const new({
    super.key,
    required this.title,
    required this.child,
    required this.icon,
  });
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final col = context.colorScheme;

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      decoration: BoxDecoration(
        color: col.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: col.outlineVariant.withValues(alpha: .3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: col.onSurfaceVariant),

          const SizedBox(height: 12),

          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: col.onSurface,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Your audio library is empty.',
            style: TextStyle(fontSize: 12, color: col.onSurfaceVariant),
          ),

          const SizedBox(height: 16),

          child,
        ],
      ),
    );
  }
}
