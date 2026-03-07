import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

import 'character_generator.dart';
import 'game.dart';

class CharacterSprite extends PositionComponent
    with HasGameReference<RealityTvGame> {
  static const _frameSize = 64.0;
  static const _columns = 2;
  static const _downRow = 2;
  static const _stepTime = 0.35;
  static const _displayScale = 4.0;

  @override
  Future<void> onLoad() async {
    final parts = await CharacterGenerator.generate();
    final displaySize = Vector2.all(_frameSize * _displayScale);
    size = displaySize;
    anchor = Anchor.center;

    for (final path in parts.layerPaths) {
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
  }
}
