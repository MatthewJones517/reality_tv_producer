import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import 'game.dart';

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

    _addOutlinedText(
      text: 'Reality TV Producer',
      position: Vector2(960, 800),
      style: const TextStyle(
        fontFamily: 'CinzelDecorative',
        fontSize: 120,
        fontWeight: FontWeight.bold,
      ),
      strokeWidth: 10,
    );

    _addOutlinedText(
      text: 'Press Space to Start',
      position: Vector2(960, 900),
      style: const TextStyle(fontFamily: 'VT323', fontSize: 80),
      strokeWidth: 6,
    );
  }

  void _addOutlinedText({
    required String text,
    required Vector2 position,
    required TextStyle style,
    required double strokeWidth,
  }) {
    final strokePaint = ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFFFFFFFF);

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
        style: style.copyWith(color: const Color(0xFFFF1493)),
      ),
    ));
  }
}
