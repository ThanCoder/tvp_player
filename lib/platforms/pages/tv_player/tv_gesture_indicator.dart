// =============================================================================
// GESTURE TYPE
// =============================================================================

import 'package:flutter/material.dart';

enum GestureType { brightness, volume }

// =============================================================================
// GESTURE INDICATOR
// =============================================================================

class TvGestureIndicator extends StatelessWidget {
  const TvGestureIndicator({
    super.key,
    required this.type,
    required this.value,
  });

  final GestureType? type;
  final double value;

  @override
  Widget build(BuildContext context) {
    if (type == null) {
      return const SizedBox.shrink();
    }

    final isBrightness = type == GestureType.brightness;

    final percentage = isBrightness ? (value * 100).round() : value.round();

    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .65),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isBrightness ? Icons.brightness_6 : Icons.volume_up,
            color: Colors.white,
            size: 34,
          ),

          const SizedBox(height: 10),

          Text(
            '$percentage%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: Colors.white24,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PLAYER CONTROLS
// =============================================================================
