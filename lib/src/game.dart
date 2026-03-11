import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'cast_screen.dart';
import 'character.dart';
import 'coin_pusher.dart';
import 'play_screen.dart';
import 'title_screen.dart';

enum GameScene { title, showName, howToPlay, cast, playing, gameOver }

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
  CastScreen? _castScreen;
  List<Character> _currentCast = [];
  CoinPusher? activePusher;

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
    _castScreen = CastScreen();
    world.add(_castScreen!);
  }

  void triggerGameOver() {
    if (_scene != GameScene.playing) return;
    _scene = GameScene.gameOver;
    overlays.add('gameOver');
    pauseEngine();
  }

  void resetToTitle() {
    overlays.remove('gameOver');
    world.children.whereType<PlayScreen>().forEach((c) => c.removeFromParent());
    world.add(TitleScreen());
    _scene = GameScene.title;
    showName = null;
    currentSeason = 1;
    _currentCast = [];
    activePusher = null;
    resumeEngine();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_scene == GameScene.playing && activePusher != null) {
      final keys = HardwareKeyboard.instance.logicalKeysPressed;
      if (keys.contains(LogicalKeyboardKey.keyD) ||
          keys.contains(LogicalKeyboardKey.arrowUp)) {
        activePusher!.rotateLauncherUp(dt);
      }
      if (keys.contains(LogicalKeyboardKey.keyA) ||
          keys.contains(LogicalKeyboardKey.arrowDown)) {
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
          _scene = GameScene.playing;
          _currentCast = List.of(_castScreen!.cast);
          _castScreen?.removeFromParent();
          _castScreen = null;
          world.add(PlayScreen(cast: _currentCast));
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
