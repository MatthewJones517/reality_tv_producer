import 'dart:developer' as developer;

import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'audio_service.dart';
import 'cast_screen.dart';
import 'character.dart';
import 'character_generator.dart';
import 'coin_pusher.dart';
import 'game_config.dart';
import 'perk.dart';
import 'play_screen.dart';
import 'title_screen.dart';

enum GameScene { title, showName, howToPlay, cast, playing, shop, gameOver, win }

class RealityTvGame extends FlameGame with KeyboardEvents {
  static const _width = 1920.0;
  static const _height = 1080.0;

  final FocusNode gameFocusNode;

  RealityTvGame({required this.gameFocusNode})
    : super(
        camera: CameraComponent.withFixedResolution(
          width: _width,
          height: _height,
        ),
      );

  GameScene _scene = GameScene.title;
  String? showName;
  int currentSeason = 1;
  int currentEpisode = 1;
  double _episodeTimer = 0;
  int coins = 0;
  final Map<Attribute, int> unlockedTokens = {};
  final Set<Perk> ownedPerks = {};
  CastScreen? _castScreen;
  List<Character> _currentCast = [];
  List<Character> get currentCast => _currentCast;
  CoinPusher? activePusher;

  String? perkFlashName;
  double perkFlashTimer = 0;

  void showPerkFlash(String name, {double duration = 1.0}) {
    perkFlashName = name;
    perkFlashTimer = duration;
  }

  @override
  Color backgroundColor() => const Color(0xFF000000);

  @override
  Future<void> onLoad() async {
    images.prefix = '';
    camera.moveTo(Vector2(_width / 2, _height / 2));
    await AudioService.instance.init();
    await AudioService.instance.playMusic(MusicTrack.intro);
    world.add(TitleScreen());
  }

  void submitShowName(String name) {
    showName = name;
    overlays.remove(Overlays.showName);
    _scene = GameScene.howToPlay;
    overlays.add(Overlays.howToPlay);
  }

  void finishHowToPlay() {
    overlays.remove(Overlays.howToPlay);
    _scene = GameScene.cast;
    world.children.whereType<TitleScreen>().forEach(
      (c) => c.removeFromParent(),
    );
    _showCastScreen();
    gameFocusNode.requestFocus();
  }

  void _showCastScreen() {
    _castScreen?.removeFromParent();
    _castScreen = CastScreen(seasonNumber: currentSeason);
    world.add(_castScreen!);
  }

  Future<List<Character>> _generateCast() async {
    final cast = <Character>[];
    for (int i = 0; i < GameConfig.castSize; i++) {
      try {
        cast.add(await CharacterGenerator.generate());
      } catch (e, st) {
        developer.log('Failed to generate character', error: e, stackTrace: st);
        rethrow;
      }
    }
    return cast;
  }

  Future<void> _advanceToNextSeason() async {
    currentSeason++;
    currentEpisode = 1;
    _episodeTimer = 0;
    coins = activePusher?.coinsCollected ?? coins;

    world.children.whereType<PlayScreen>().forEach((c) => c.removeFromParent());
    activePusher = null;

    await AudioService.instance.playMusic(MusicTrack.seasonChange);

    _currentCast = await _generateCast();

    _castScreen?.removeFromParent();
    _castScreen = CastScreen(
      seasonNumber: currentSeason,
      initialCast: _currentCast,
    );
    world.add(_castScreen!);
    _scene = GameScene.cast;
    overlays.add(Overlays.castCooldown);
    gameFocusNode.requestFocus();
  }

  int _rerollCount = 0;

  int get rerollCost => GameConfig.rerollBaseCost * (1 << _rerollCount);

  bool performReroll() {
    if (coins < rerollCost) return false;
    coins -= rerollCost;
    _rerollCount++;
    return true;
  }

  Future<void> rerollContestants() async {
    if (currentSeason < GameConfig.rerollSeasonMinimum) return;
    if (!performReroll()) return;

    _currentCast = await _generateCast();

    _castScreen?.removeFromParent();
    _castScreen = CastScreen(
      seasonNumber: currentSeason,
      initialCast: _currentCast,
    );
    world.add(_castScreen!);
  }

  void proceedFromCastScreen() {
    overlays.remove(Overlays.castCooldown);
    final screen = _castScreen;
    if (screen != null) {
      _currentCast = List.of(screen.cast);
      screen.removeFromParent();
    }
    _castScreen = null;
    _scene = GameScene.playing;
    AudioService.instance.playMusic(MusicTrack.playfield);
    world.add(PlayScreen(cast: _currentCast, initialCoins: coins));
    gameFocusNode.requestFocus();
  }

  bool purchaseAttribute(Attribute attr) {
    final current = unlockedTokens[attr] ?? 0;
    if (current >= GameConfig.maxAttributeLevel) return false;
    final cost = ShopConfig.costForLevel(current);
    if (coins < cost) return false;
    coins -= cost;
    unlockedTokens[attr] = current + 1;
    if (current == 0) {
      activePusher?.convertDramaToAttribute(
        attr,
        unlockedTokens[attr] ?? 1,
      );
    }
    return true;
  }

  bool purchasePerk(Perk perk) {
    if (coins < ShopConfig.perkCost) return false;
    if (ownedPerks.contains(perk)) return false;
    coins -= ShopConfig.perkCost;
    ownedPerks.add(perk);
    return true;
  }

  void finishShop() {
    overlays.remove(Overlays.shop);
    activePusher?.coinsCollected = coins;
    resumeEngine();
  }

  void triggerWin() {
    if (_scene != GameScene.playing) return;
    AudioService.instance.stopMusic();
    coins = activePusher?.coinsCollected ?? coins;
    _scene = GameScene.win;
    overlays.add(Overlays.win);
    pauseEngine();
  }

  void triggerGameOver() {
    if (_scene != GameScene.playing) return;
    AudioService.instance.stopMusic();
    _scene = GameScene.gameOver;
    overlays.add(Overlays.gameOver);
    pauseEngine();
  }

  void resetToTitle() {
    overlays.remove(Overlays.gameOver);
    overlays.remove(Overlays.win);
    world.children.whereType<PlayScreen>().forEach((c) => c.removeFromParent());
    _castScreen?.removeFromParent();
    _castScreen = null;
    world.add(TitleScreen());
    _scene = GameScene.title;
    AudioService.instance.playMusic(MusicTrack.intro);
    showName = null;
    currentSeason = 1;
    currentEpisode = 1;
    _episodeTimer = 0;
    coins = 0;
    unlockedTokens.clear();
    ownedPerks.clear();
    _rerollCount = 0;
    perkFlashName = null;
    perkFlashTimer = 0;
    _currentCast = [];
    activePusher = null;
    resumeEngine();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (perkFlashTimer > 0) {
      perkFlashTimer -= dt;
      if (perkFlashTimer <= 0) perkFlashName = null;
    }
    final pusher = activePusher;
    if (_scene == GameScene.playing && pusher != null) {
      _episodeTimer += dt;
      while (_episodeTimer >= GameConfig.episodeDurationSeconds) {
        _episodeTimer -= GameConfig.episodeDurationSeconds;
        currentEpisode++;

        if (currentEpisode % GameConfig.shopTriggerInterval == 0 &&
            currentEpisode < GameConfig.episodesPerSeason) {
          coins = pusher.coinsCollected;
          overlays.add(Overlays.shop);
          pauseEngine();
          return;
        }
        if (currentEpisode > GameConfig.episodesPerSeason) {
          if (currentSeason >= GameConfig.seasonsToWin) {
            triggerWin();
            return;
          } else {
            _advanceToNextSeason();
            return;
          }
        }
      }

      final keys = HardwareKeyboard.instance.logicalKeysPressed;
      if (keys.contains(LogicalKeyboardKey.keyD) ||
          keys.contains(LogicalKeyboardKey.arrowDown)) {
        pusher.rotateLauncherUp(dt);
      }
      if (keys.contains(LogicalKeyboardKey.keyA) ||
          keys.contains(LogicalKeyboardKey.arrowUp)) {
        pusher.rotateLauncherDown(dt);
      }
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      switch (_scene) {
        case GameScene.title:
          _scene = GameScene.showName;
          overlays.add(Overlays.showName);
          return KeyEventResult.handled;
        case GameScene.cast:
          if (overlays.isActive(Overlays.castCooldown)) {
            return KeyEventResult.ignored;
          }
          proceedFromCastScreen();
          return KeyEventResult.handled;
        case GameScene.playing:
          activePusher?.shoot();
          return KeyEventResult.handled;
        default:
          break;
      }
    }
    return KeyEventResult.ignored;
  }
}
