import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import 'game.dart';

class _DarkPanel extends PositionComponent {
  _DarkPanel({required super.position, required super.size, required super.anchor});

  @override
  void render(ui.Canvas canvas) {
    canvas.drawRRect(
      ui.RRect.fromRectAndRadius(size.toRect(), const ui.Radius.circular(24)),
      ui.Paint()..color = const Color(0xCC000000),
    );
  }
}

class TitleScreen extends PositionComponent
    with HasGameReference<RealityTvGame> {
  @override
  Future<void> onLoad() async {
    size = Vector2(1920, 1080);

    final bgImage = await game.images.load('assets/title_screen/bg.png');
    add(SpriteComponent(
      sprite: Sprite(bgImage),
      size: Vector2(1920, 1080),
    ));

    add(_DarkPanel(
      position: Vector2(960, 540),
      size: Vector2(1400, 500),
      anchor: Anchor.center,
    ));

    _addOutlinedText(
      text: 'Reality TV\nProducer',
      position: Vector2(960, 480),
      style: const TextStyle(
        fontFamily: 'CinzelDecorative',
        fontSize: 120,
        fontWeight: FontWeight.bold,
      ),
      fillColor: const Color(0xFFFF1493),
      strokeColor: const Color(0xFF1A0010),
      strokeWidth: 8,
    );

    _addOutlinedText(
      text: 'Press Space to Start',
      position: Vector2(960, 700),
      style: const TextStyle(fontFamily: 'VT323', fontSize: 80),
      fillColor: const Color(0xFFFFFFFF),
      strokeColor: const Color(0xFF1A0010),
      strokeWidth: 5,
    );
  }

  void _addOutlinedText({
    required String text,
    required Vector2 position,
    required TextStyle style,
    required Color fillColor,
    required Color strokeColor,
    required double strokeWidth,
  }) {
    final strokePaint = ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = strokeColor;

    add(TextComponent(
      text: text,
      position: position,
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: style.copyWith(foreground: strokePaint),
      ),
    ));

    add(TextComponent(
      text: text,
      position: position,
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: style.copyWith(color: fillColor),
      ),
    ));
  }
}
