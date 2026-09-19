import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:tvp_player/core/models/v_file.dart';

class TvPlayerControls extends StatelessWidget {
  const TvPlayerControls({
    super.key,
    required this.file,
    required this.player,
    required this.onBack,
    required this.onPlayPause,
    required this.onSeekBack,
    required this.onSeekForward,
    required this.onInteraction,
  });

  final VFile file;
  final Player player;

  final VoidCallback onBack;
  final VoidCallback onPlayPause;
  final VoidCallback onSeekBack;
  final VoidCallback onSeekForward;
  final VoidCallback onInteraction;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // =====================================================================
        // TOP
        // =====================================================================

        Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 78,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: .9),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),

                Expanded(
                  child: Text(
                    file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                ),
              ],
            ),
          ),
        ),

        // =====================================================================
        // CENTER
        // =====================================================================
        Center(
          child: StreamBuilder<bool>(
            stream: player.stream.playing,
            builder: (context, snapshot) {
              final playing = snapshot.data ?? false;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CircleButton(icon: Icons.replay_10, onPressed: onSeekBack),

                  const SizedBox(width: 34),

                  _PlayButton(playing: playing, onPressed: onPlayPause),

                  const SizedBox(width: 34),

                  _CircleButton(
                    icon: Icons.forward_10,
                    onPressed: onSeekForward,
                  ),
                ],
              );
            },
          ),
        ),

        // =====================================================================
        // BOTTOM
        // =====================================================================
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 30, 12, 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: .92),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Seek
                StreamBuilder<Duration>(
                  stream: player.stream.position,
                  builder: (context, positionSnapshot) {
                    final position = positionSnapshot.data ?? Duration.zero;

                    return StreamBuilder<Duration>(
                      stream: player.stream.duration,
                      builder: (context, durationSnapshot) {
                        final duration = durationSnapshot.data ?? Duration.zero;

                        final max = math.max(duration.inMilliseconds, 1);

                        final value = position.inMilliseconds
                            .clamp(0, max)
                            .toDouble();

                        return Slider(
                          min: 0,
                          max: max.toDouble(),
                          value: value,
                          onChanged: duration.inMilliseconds <= 0
                              ? null
                              : (value) {
                                  player.seek(
                                    Duration(milliseconds: value.toInt()),
                                  );

                                  onInteraction();
                                },
                        );
                      },
                    );
                  },
                ),

                // Time / actions
                StreamBuilder<Duration>(
                  stream: player.stream.position,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;

                    return StreamBuilder<Duration>(
                      stream: player.stream.duration,
                      builder: (context, snapshot) {
                        final duration = snapshot.data ?? Duration.zero;

                        return Row(
                          children: [
                            Text(
                              _formatDuration(position),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),

                            const Text(
                              ' / ',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),

                            Text(
                              _formatDuration(duration),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),

                            const Spacer(),

                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.speed,
                                color: Colors.white,
                              ),
                            ),

                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.subtitles_outlined,
                                color: Colors.white,
                              ),
                            ),

                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.fullscreen,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// PLAY
// =============================================================================

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.playing, required this.onPressed});

  final bool playing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .16),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 72,
          height: 72,
          child: Icon(
            !playing ? Icons.play_arrow : Icons.pause_outlined,
            color: Colors.white,
            size: 42,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// CIRCLE
// =============================================================================

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: .28),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

// =============================================================================
// FORMAT
// =============================================================================

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  if (hours > 0) {
    return '$hours:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  return '$minutes:'
      '${seconds.toString().padLeft(2, '0')}';
}
