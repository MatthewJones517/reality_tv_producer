import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/painting.dart';

import 'character.dart';
import 'character_generator.dart';
import 'game.dart';

class CastScreen extends PositionComponent
    with HasGameReference<RealityTvGame> {
  static const _frameSize = 64.0;
  static const _columns = 2;
  static const _downRow = 2;
  static const _stepTime = 0.35;
  static const _displayScale = 4.0;

  final int seasonNumber;
  final List<Character> cast = [];

  CastScreen({this.seasonNumber = 1});

  @override
  Future<void> onLoad() async {
    size = Vector2(1920, 1080);

    final bgImage = await game.images.load('assets/title_screen/bg.png');
    add(SpriteComponent(sprite: Sprite(bgImage), size: Vector2(1920, 1080)));

    add(_DarkPanel(
      position: Vector2(960, 540),
      size: Vector2(1600, 900),
      anchor: Anchor.center,
    ));

    _addOutlinedText(
      text: 'Season One Cast',
      position: Vector2(960, 150),
      style: const TextStyle(
        fontFamily: 'CinzelDecorative',
        fontSize: 72,
        fontWeight: FontWeight.bold,
      ),
      fillColor: const Color(0xFFFF1493),
      strokeColor: const Color(0xFF1A0010),
      strokeWidth: 6,
    );

    for (int i = 0; i < 4; i++) {
      cast.add(await CharacterGenerator.generate());
    }

    final displaySize = Vector2.all(_frameSize * _displayScale);
    const spacing = 400.0;
    final startX = 960.0 - (spacing * 1.5);

    for (int i = 0; i < 4; i++) {
      final character = cast[i];
      final centerX = startX + (spacing * i);
      final baseY = 280.0;

      final container = PositionComponent(
        position: Vector2(centerX, baseY),
        anchor: Anchor.topCenter,
      );

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
        container.add(SpriteAnimationComponent(
          animation: animation,
          size: displaySize,
          position: Vector2(-displaySize.x / 2, 0),
        ));
      }

      final nameRenderer = TextPaint(
        style: const TextStyle(
          fontFamily: 'VT323',
          fontSize: 44,
          color: Color(0xFFFFFFFF),
        ),
      );
      container.add(TextComponent(
        text: character.fullName,
        anchor: Anchor.topCenter,
        position: Vector2(0, displaySize.y + 8),
        textRenderer: nameRenderer,
      ));

      final attrRenderer = TextPaint(
        style: const TextStyle(
          fontFamily: 'VT323',
          fontSize: 36,
          color: Color(0xFFFF1493),
        ),
      );
      container.add(TextComponent(
        text: character.attributes.map((a) => a.label).join(' · '),
        anchor: Anchor.topCenter,
        position: Vector2(0, displaySize.y + 52),
        textRenderer: attrRenderer,
      ));

      final factRenderer = TextPaint(
        style: const TextStyle(
          fontFamily: 'VT323',
          fontSize: 32,
          color: Color(0xFFBBBBBB),
        ),
      );

      final factLines = _wrapText('"${character.funFact}"', 18).split('\n');
      for (int l = 0; l < factLines.length; l++) {
        container.add(TextComponent(
          text: factLines[l],
          anchor: Anchor.topCenter,
          position: Vector2(0, displaySize.y + 104 + (l * 34)),
          textRenderer: factRenderer,
        ));
      }

      add(container);
    }

    _addOutlinedText(
      text: 'Press Space to Continue',
      position: Vector2(960, 940),
      style: const TextStyle(fontFamily: 'VT323', fontSize: 48),
      fillColor: const Color(0xFFFFFFFF),
      strokeColor: const Color(0xFF1A0010),
      strokeWidth: 4,
    );
  }

  String _wrapText(String text, int maxChars) {
    final words = text.split(' ');
    final lines = <String>[];
    var current = '';
    for (final word in words) {
      if (current.isEmpty) {
        current = word;
      } else if (current.length + 1 + word.length <= maxChars) {
        current += ' $word';
      } else {
        lines.add(current);
        current = word;
      }
    }
    if (current.isNotEmpty) lines.add(current);
    return lines.join('\n');
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

class _DarkPanel extends PositionComponent {
  _DarkPanel({
    required super.position,
    required super.size,
    required super.anchor,
  });

  @override
  void render(ui.Canvas canvas) {
    canvas.drawRRect(
      ui.RRect.fromRectAndRadius(size.toRect(), const ui.Radius.circular(24)),
      ui.Paint()..color = const Color(0xCC000000),
    );
  }
}
