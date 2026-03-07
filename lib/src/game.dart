import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'character_sprite.dart';

class RealityTvGame extends FlameGame with KeyboardEvents {
  CharacterSprite? _character;
  bool _spawning = false;

  @override
  Color backgroundColor() => const Color(0xFF2D2D2D);

  @override
  Future<void> onLoad() async {
    images.prefix = '';
    await _spawnCharacter();
  }

  Future<void> _spawnCharacter() async {
    if (_spawning) return;
    _spawning = true;
    try {
      _character?.removeFromParent();
      _character = CharacterSprite();
      await add(_character!);
      _character!.position = size / 2;
    } finally {
      _spawning = false;
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      _spawnCharacter();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
