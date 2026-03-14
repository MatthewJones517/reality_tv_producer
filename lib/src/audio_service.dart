import 'dart:developer' as developer;

import 'package:flame_audio/flame_audio.dart';

enum MusicTrack { intro, playfield, seasonChange }

enum Sfx { coin, continuePress, fail, win, shoot }

class AudioService {
  static final AudioService instance = AudioService._();

  AudioService._();

  bool _initialized = false;
  MusicTrack? _currentTrack;

  static const _sfxVolume = <Sfx, double>{
    Sfx.coin: 0.25,
    Sfx.fail: 0.75,
    Sfx.shoot: 0.4,
  };

  static const _sfxMaxInstances = <Sfx, int>{Sfx.coin: 3};

  final Map<Sfx, int> _activeSfxCount = {};

  static const _musicPaths = <MusicTrack, String>{
    MusicTrack.intro: 'music/intro.mp3',
    MusicTrack.playfield: 'music/playfield.mp3',
    MusicTrack.seasonChange: 'music/season-change.mp3',
  };

  static const _sfxPaths = <Sfx, String>{
    Sfx.coin: 'sfx/coin.mp3',
    Sfx.continuePress: 'sfx/continue.mp3',
    Sfx.fail: 'sfx/fail.mp3',
    Sfx.win: 'sfx/win.mp3',
    Sfx.shoot: 'sfx/shoot.mp3',
  };

  Future<void> init() async {
    if (_initialized) return;
    try {
      FlameAudio.audioCache.prefix = 'assets/';
      await FlameAudio.audioCache.loadAll([..._sfxPaths.values]);
      _initialized = true;
    } catch (e, st) {
      developer.log('AudioService init failed', error: e, stackTrace: st);
    }
  }

  Future<void> playMusic(MusicTrack track) async {
    if (!_initialized) return;
    if (_currentTrack == track) return;

    await stopMusic();

    final path = _musicPaths[track];
    if (path == null) return;

    try {
      await FlameAudio.bgm.play(path);
      _currentTrack = track;
    } catch (e, st) {
      developer.log('AudioService playMusic failed', error: e, stackTrace: st);
    }
  }

  void playSfx(Sfx sfx) {
    if (!_initialized) return;
    final path = _sfxPaths[sfx];
    if (path == null) return;

    final maxInstances = _sfxMaxInstances[sfx];
    if (maxInstances != null) {
      final active = _activeSfxCount[sfx] ?? 0;
      if (active >= maxInstances) return;
      _activeSfxCount[sfx] = active + 1;
    }

    final volume = _sfxVolume[sfx] ?? 1.0;
    try {
      FlameAudio.play(path, volume: volume).then((player) {
        if (maxInstances != null) {
          player.onPlayerComplete.first.then((_) {
            final count = _activeSfxCount[sfx] ?? 1;
            _activeSfxCount[sfx] = count > 0 ? count - 1 : 0;
          });
        }
      });
    } catch (e, st) {
      if (maxInstances != null) {
        final count = _activeSfxCount[sfx] ?? 1;
        _activeSfxCount[sfx] = count > 0 ? count - 1 : 0;
      }
      developer.log('AudioService playSfx failed', error: e, stackTrace: st);
    }
  }

  Future<void> stopMusic() async {
    if (!_initialized) return;
    try {
      await FlameAudio.bgm.stop();
    } catch (e, st) {
      developer.log('AudioService stopMusic failed', error: e, stackTrace: st);
    }
    _currentTrack = null;
  }

  Future<void> dispose() async {
    await stopMusic();
    FlameAudio.bgm.dispose();
    _initialized = false;
  }
}
