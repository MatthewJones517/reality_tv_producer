import 'dart:developer' as developer;

import 'package:flutter_soloud/flutter_soloud.dart';

enum MusicTrack { intro, playfield, seasonChange }

enum Sfx { coin, continuePress, fail, win }

class AudioService {
  static final AudioService instance = AudioService._();

  AudioService._();

  bool _initialized = false;

  AudioSource? _introSource;
  AudioSource? _playfieldSource;
  AudioSource? _seasonChangeSource;

  final Map<Sfx, AudioSource> _sfxSources = {};

  static const _sfxVolume = <Sfx, double>{
    Sfx.coin: 0.25,
  };

  static const _sfxMaxInstances = <Sfx, int>{
    Sfx.coin: 3,
  };

  SoundHandle? _currentMusicHandle;
  MusicTrack? _currentTrack;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await SoLoud.instance.init();
      _introSource = await SoLoud.instance.loadAsset(
        'assets/music/intro.mp3',
      );
      _playfieldSource = await SoLoud.instance.loadAsset(
        'assets/music/playfield.mp3',
      );
      _seasonChangeSource = await SoLoud.instance.loadAsset(
        'assets/music/season-change.mp3',
      );

      _sfxSources[Sfx.coin] = await SoLoud.instance.loadAsset(
        'assets/sfx/coin.mp3',
      );
      _sfxSources[Sfx.continuePress] = await SoLoud.instance.loadAsset(
        'assets/sfx/continue.mp3',
      );
      _sfxSources[Sfx.fail] = await SoLoud.instance.loadAsset(
        'assets/sfx/fail.mp3',
      );
      _sfxSources[Sfx.win] = await SoLoud.instance.loadAsset(
        'assets/sfx/win.mp3',
      );

      _initialized = true;
    } catch (e, st) {
      developer.log('AudioService init failed', error: e, stackTrace: st);
    }
  }

  Future<void> playMusic(MusicTrack track) async {
    if (!_initialized) return;
    if (_currentTrack == track) return;

    await stopMusic();

    final source = switch (track) {
      MusicTrack.intro => _introSource,
      MusicTrack.playfield => _playfieldSource,
      MusicTrack.seasonChange => _seasonChangeSource,
    };
    if (source == null) return;

    try {
      _currentMusicHandle = await SoLoud.instance.play(
        source,
        looping: true,
      );
      _currentTrack = track;
    } catch (e, st) {
      developer.log('AudioService play failed', error: e, stackTrace: st);
    }
  }

  void playSfx(Sfx sfx) {
    if (!_initialized) return;
    final source = _sfxSources[sfx];
    if (source == null) return;

    final maxInstances = _sfxMaxInstances[sfx];
    if (maxInstances != null && source.handles.length >= maxInstances) return;

    final volume = _sfxVolume[sfx] ?? 1.0;
    try {
      SoLoud.instance.play(source, volume: volume);
    } catch (e, st) {
      developer.log('AudioService playSfx failed', error: e, stackTrace: st);
    }
  }

  Future<void> stopMusic() async {
    if (!_initialized) return;
    final handle = _currentMusicHandle;
    if (handle != null) {
      try {
        SoLoud.instance.stop(handle);
      } catch (e, st) {
        developer.log('AudioService stop failed', error: e, stackTrace: st);
      }
    }
    _currentMusicHandle = null;
    _currentTrack = null;
  }

  Future<void> dispose() async {
    await stopMusic();
    if (_introSource != null) {
      await SoLoud.instance.disposeSource(_introSource!);
    }
    if (_playfieldSource != null) {
      await SoLoud.instance.disposeSource(_playfieldSource!);
    }
    if (_seasonChangeSource != null) {
      await SoLoud.instance.disposeSource(_seasonChangeSource!);
    }
    for (final source in _sfxSources.values) {
      await SoLoud.instance.disposeSource(source);
    }
    _sfxSources.clear();
    SoLoud.instance.deinit();
    _initialized = false;
  }
}
