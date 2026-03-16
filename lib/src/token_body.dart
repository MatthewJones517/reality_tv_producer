import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:forge2d/forge2d.dart' as f2d;

import 'character.dart';

enum TokenType { coin, drama }

/// Represents a token in the queue or for spawning.
sealed class QueueToken {}

class CoinQueueToken extends QueueToken {}

class DramaQueueToken extends QueueToken {}

class AttributeQueueToken extends QueueToken {
  final Attribute attribute;
  final int level;
  AttributeQueueToken(this.attribute, this.level);
}

class TokenBody extends PositionComponent {
  static const coinDiameter = 40.0;
  static const dramaDiameter = 120.0;

  static double diameterFor(TokenType t) =>
      t == TokenType.coin ? coinDiameter : dramaDiameter;

  static double diameterForQueueToken(QueueToken t) {
    return switch (t) {
      CoinQueueToken() => coinDiameter,
      DramaQueueToken() || AttributeQueueToken() => dramaDiameter,
    };
  }

  static String assetPathForQueueToken(QueueToken t) {
    return switch (t) {
      CoinQueueToken() => 'assets/playfield/coin.png',
      DramaQueueToken() => 'assets/playfield/Drama_Chip.png',
      AttributeQueueToken(attribute: final a) =>
        'assets/playfield/${a.name[0].toUpperCase()}${a.name.substring(1)}_Chip.png',
    };
  }

  final TokenType type;
  Attribute? attribute;
  int attributeLevel;
  final f2d.Body body;
  final double physScale;
  Sprite? _sprite;
  static final ui.Paint _spritePaint = ui.Paint()
    ..filterQuality = ui.FilterQuality.low;

  TokenBody({
    required this.type,
    required this.body,
    required this.physScale,
    this.attribute,
    this.attributeLevel = 1,
  }) {
    final d = type == TokenType.coin ? coinDiameter : dramaDiameter;
    size = Vector2.all(d);
    anchor = Anchor.center;
    body.userData = this;
  }

  bool get isAttributeToken => attribute != null;

  bool collected = false;

  Future<void> convertToAttribute(
    Attribute attr,
    int level,
    Future<ui.Image> Function(String) imageLoader,
  ) async {
    attribute = attr;
    attributeLevel = level;
    await loadSprite(imageLoader);
  }

  Future<void> loadSprite(Future<ui.Image> Function(String) imageLoader) async {
    final path = switch ((type, attribute)) {
      (TokenType.coin, _) => 'assets/playfield/coin.png',
      (TokenType.drama, null) => 'assets/playfield/Drama_Chip.png',
      (TokenType.drama, final a) =>
        a != null
            ? 'assets/playfield/${a.name[0].toUpperCase()}${a.name.substring(1)}_Chip.png'
            : 'assets/playfield/Drama_Chip.png',
    };
    final image = await imageLoader(path);
    _sprite = Sprite(image);
  }

  @override
  void update(double dt) {
    final pos = body.position;
    position.setValues(pos.x / physScale, pos.y / physScale);
    angle = body.angle;
  }

  @override
  void render(ui.Canvas canvas) {
    _sprite?.render(canvas, size: size, overridePaint: _spritePaint);
  }
}
