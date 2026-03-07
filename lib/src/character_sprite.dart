import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/painting.dart';

import 'character.dart';
import 'character_generator.dart';
import 'game.dart';

class CharacterSprite extends PositionComponent
    with HasGameReference<RealityTvGame> {
  static const _frameSize = 64.0;
  static const _columns = 2;
  static const _downRow = 2;
  static const _stepTime = 0.35;
  static const _displayScale = 4.0;

  late final Character character;

  @override
  Future<void> onLoad() async {
    character = await CharacterGenerator.generate();
    final displaySize = Vector2.all(_frameSize * _displayScale);
    size = displaySize;
    anchor = Anchor.center;

    for (final path in character.parts.layerPaths) {
      final image = await game.images.load(path);
      final sheet = SpriteSheet(
        image: image,
        srcSize: Vector2.all(_frameSize),
      );
      final animation = sheet.createAnimation(
        row: _downRow,
        stepTime: _stepTime,
        to: _columns,
      );
      add(SpriteAnimationComponent(
        animation: animation,
        size: displaySize,
      ));
    }

    final nameRenderer = TextPaint(
      style: const TextStyle(fontSize: 20, color: Color(0xFFFFFFFF)),
    );
    final attrRenderer = TextPaint(
      style: const TextStyle(fontSize: 14, color: Color(0xFFBBBBBB)),
    );

    add(TextComponent(
      text: character.fullName,
      anchor: Anchor.topCenter,
      position: Vector2(displaySize.x / 2, displaySize.y + 4),
      textRenderer: nameRenderer,
    ));

    add(TextComponent(
      text: character.attributes.map((a) => a.label).join(' · '),
      anchor: Anchor.topCenter,
      position: Vector2(displaySize.x / 2, displaySize.y + 28),
      textRenderer: attrRenderer,
    ));
  }
}
