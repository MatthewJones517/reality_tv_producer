import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:forge2d/forge2d.dart' as f2d;

enum TokenType { coin, drama }

class TokenBody extends PositionComponent {
  static const coinDiameter = 40.0;
  static const dramaDiameter = 120.0;

  static double diameterFor(TokenType t) =>
      t == TokenType.coin ? coinDiameter : dramaDiameter;

  final TokenType type;
  final f2d.Body body;
  final double physScale;
  Sprite? _sprite;

  TokenBody({
    required this.type,
    required this.body,
    required this.physScale,
  }) {
    final d = diameterFor(type);
    size = Vector2.all(d);
    anchor = Anchor.center;
    body.userData = this;
  }

  bool collected = false;

  Future<void> loadSprite(
    Future<ui.Image> Function(String) imageLoader,
  ) async {
    final path = type == TokenType.coin
        ? 'assets/playfield/coin.png'
        : 'assets/playfield/Drama_Chip.png';
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
    _sprite?.render(
      canvas,
      size: size,
      overridePaint: ui.Paint()..filterQuality = ui.FilterQuality.low,
    );
  }
}
