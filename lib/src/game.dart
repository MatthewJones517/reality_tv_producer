import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'title_screen.dart';

class RealityTvGame extends FlameGame with KeyboardEvents {
  static const _width = 1920.0;
  static const _height = 1080.0;

  RealityTvGame()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: _width,
            height: _height,
          ),
        );

  bool _onTitleScreen = true;
  String? showName;

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
    // TODO: proceed to character selection
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.space) {
      if (_onTitleScreen) {
        _onTitleScreen = false;
        overlays.add('showName');
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
}
