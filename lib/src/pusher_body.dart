import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:forge2d/forge2d.dart' as f2d;

class PusherBody extends PositionComponent {
  final f2d.Body body;
  final double physScale;
  final double fieldHeight;
  final double pushDistance;
  final double pushSpeed;
  final double startX;
  final ui.Image image;

  static const _physicsWidth = 16.0;

  bool _movingRight = true;

  PusherBody({
    required this.body,
    required this.physScale,
    required this.fieldHeight,
    required this.pushDistance,
    required this.pushSpeed,
    required this.startX,
    required this.image,
  }) {
    size = Vector2(pushDistance + 500, fieldHeight);
    anchor = Anchor.centerRight;
    body.userData = this;
  }

  @override
  void update(double dt) {
    final posX = body.position.x / physScale;

    if (_movingRight && posX >= startX + pushDistance) {
      _movingRight = false;
      body.linearVelocity = f2d.Vector2(-pushSpeed, 0);
    } else if (!_movingRight && posX <= startX) {
      _movingRight = true;
      body.linearVelocity = f2d.Vector2(pushSpeed, 0);
    }

    final pos = body.position;
    position.setValues(pos.x / physScale + _physicsWidth / 2, pos.y / physScale);
  }

  @override
  void render(ui.Canvas canvas) {
    final srcRect = ui.Rect.fromLTWH(
        0, 0, image.width.toDouble(), image.height.toDouble());
    final dstRect = size.toRect();
    canvas.drawImageRect(
        image, srcRect, dstRect, ui.Paint()..filterQuality = ui.FilterQuality.low);
  }
}
