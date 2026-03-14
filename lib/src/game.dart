import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'cast_screen.dart';
import 'character.dart';
import 'character_generator.dart';
import 'coin_pusher.dart';
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
    world.add(TitleScreen());
  }

  void submitShowName(String name) {
    showName = name;
    overlays.remove('showName');
    _scene = GameScene.howToPlay;
    overlays.add('howToPlay');
  }

  void finishHowToPlay() {
    overlays.remove('howToPlay');
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

  void _advanceToNextSeason() async {
    currentSeason++;
    currentEpisode = 1;
    _episodeTimer = 0;
    coins = activePusher?.coinsCollected ?? coins;

    world.children.whereType<PlayScreen>().forEach((c) => c.removeFromParent());
    activePusher = null;

    _currentCast = [];
    for (int i = 0; i < 4; i++) {
      _currentCast.add(await CharacterGenerator.generate());
    }

    _castScreen?.removeFromParent();
    _castScreen = CastScreen(
      seasonNumber: currentSeason,
      initialCast: _currentCast,
    );
    world.add(_castScreen!);
    _scene = GameScene.cast;
    overlays.add('castCooldown');
    gameFocusNode.requestFocus();
  }

  int _rerollCount = 0;

  int get rerollCost => 5 * (1 << _rerollCount);

  bool performReroll() {
    if (coins < rerollCost) return false;
    coins -= rerollCost;
    _rerollCount++;
    return true;
  }

  void rerollContestants() async {
    if (currentSeason < 2) return;
    if (!performReroll()) return;
    _currentCast = [];
    for (int i = 0; i < 4; i++) {
      _currentCast.add(await CharacterGenerator.generate());
    }
    _castScreen?.removeFromParent();
    _castScreen = CastScreen(
      seasonNumber: currentSeason,
      initialCast: _currentCast,
    );
    world.add(_castScreen!);
  }

  void proceedFromCastScreen() {
    overlays.remove('castCooldown');
    _currentCast = List.of(_castScreen!.cast);
    _castScreen?.removeFromParent();
    _castScreen = null;
    _scene = GameScene.playing;
    world.add(PlayScreen(cast: _currentCast, initialCoins: coins));
    gameFocusNode.requestFocus();
  }

  void convertDramaToAttribute(Attribute attr) {
    final level = unlockedTokens[attr] ?? 1;
    activePusher?.convertDramaToAttribute(attr, level);
  }

  void finishShop() {
    overlays.remove('shop');
    activePusher?.coinsCollected = coins;
    resumeEngine();
  }

  void triggerWin() {
    if (_scene != GameScene.playing) return;
    coins = activePusher?.coinsCollected ?? coins;
    _scene = GameScene.win;
    overlays.add('win');
    pauseEngine();
  }

  void triggerGameOver() {
    if (_scene != GameScene.playing) return;
    _scene = GameScene.gameOver;
    overlays.add('gameOver');
    pauseEngine();
  }

  void resetToTitle() {
    overlays.remove('gameOver');
    overlays.remove('win');
    world.children.whereType<PlayScreen>().forEach((c) => c.removeFromParent());
    _castScreen?.removeFromParent();
    _castScreen = null;
    world.add(TitleScreen());
    _scene = GameScene.title;
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
    if (_scene == GameScene.playing && activePusher != null) {
      _episodeTimer += dt;
      while (_episodeTimer >= 10) {
        _episodeTimer -= 10;
        currentEpisode++;

        if (currentEpisode % 3 == 0 && currentEpisode < 12) {
          coins = activePusher!.coinsCollected;
          overlays.add('shop');
          pauseEngine();
          return;
        }
        if (currentEpisode > 12) {
          if (currentSeason >= 5) {
            triggerWin();
            return;
          } else {
            _advanceToNextSeason();
            return;
          }
        }
      }

      final keys = HardwareKeyboard.instance.logicalKeysPressed;
      activePusher!.skillStopPressed =
          keys.contains(LogicalKeyboardKey.keyS);
      if (keys.contains(LogicalKeyboardKey.keyD) ||
          keys.contains(LogicalKeyboardKey.arrowDown)) {
        activePusher!.rotateLauncherUp(dt);
      }
      if (keys.contains(LogicalKeyboardKey.keyA) ||
          keys.contains(LogicalKeyboardKey.arrowUp)) {
        activePusher!.rotateLauncherDown(dt);
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
          overlays.add('showName');
          return KeyEventResult.handled;
        case GameScene.cast:
          if (overlays.isActive('castCooldown')) {
            return KeyEventResult.ignored;
          }
          _scene = GameScene.playing;
          _currentCast = List.of(_castScreen!.cast);
          _castScreen?.removeFromParent();
          _castScreen = null;
          world.add(PlayScreen(cast: _currentCast, initialCoins: coins));
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
