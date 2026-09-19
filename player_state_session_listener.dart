// ignore_for_file: avoid_print, experimental_member_use
/*
class PlayerStateSessionListener {
  final PlayerStateController _controller;
  PlayerStateSessionListener({required this._controller});

  Player get player => _controller.player;

  bool _init = false;
  Future<void> init() async {
    if (_init) return;
    _init = true;

    if (!Platform.isAndroid) return;
    final session = await AudioSession.instance;

    session.becomingNoisyEventStream.listen((_) {
      // The user unplugged the headphones, so we should pause or lower the volume.
      print('[dev:session]: user unplugged the headphones');
      player.pause();
    });

    session.devicesChangedEventStream.listen((event) {
      print('[dev:session]:Devices added:   ${event.devicesAdded}');
      print('[dev:session]: Devices removed: ${event.devicesRemoved}');
      for (var deviceRemoved in event.devicesRemoved) {
        // bluetooth
        if (deviceRemoved.type == .bluetoothA2dp ||
            deviceRemoved.type == .bluetoothLe ||
            deviceRemoved.type == .bluetoothSco) {
          player.pause();
        }
        // // wried
        // if (deviceRemoved.type == .wiredHeadset ||
        //     deviceRemoved.type == .wiredHeadphones) {
        //   player.pause();
        // }
      }
    });

    // print('[dev:session]:');

    bool wasPlayingBeforeInterruption = false;

    session.interruptionEventStream.listen((event) async {
      print(
        '[dev:session] '
        'begin=${event.begin}, '
        'type=${event.type}, '
        'playing=${player.state.playing}',
      );

      if (event.begin) {
        wasPlayingBeforeInterruption = player.state.playing;

        print(
          '[dev:session] interruption started '
          'wasPlaying=$wasPlayingBeforeInterruption',
        );

        switch (event.type) {
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            if (wasPlayingBeforeInterruption) {
              print('[dev:session] -> pause()');
              await player.pause();
              print('[dev:session] -> pause() done');
            }
            break;

          case AudioInterruptionType.duck:
            break;
        }

        return;
      }

      print(
        '[dev:session] interruption ended '
        'wasPlaying=$wasPlayingBeforeInterruption',
      );

      if (!wasPlayingBeforeInterruption) {
        print('[dev:session] -> was not playing, do nothing');
        return;
      }

      switch (event.type) {
        case AudioInterruptionType.pause:
          print('[dev:session] -> play()');

          await player.play();

          print(
            '[dev:session] -> play() done '
            'playing=${player.state.playing}',
          );
          break;

        case AudioInterruptionType.unknown:
          break;

        case AudioInterruptionType.duck:
          break;
      }

      wasPlayingBeforeInterruption = false;
    });
  }
}

*/