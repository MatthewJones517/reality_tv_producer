import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/painting.dart';

import 'character.dart';
import 'coin_pusher.dart';
import 'game.dart';
import 'token_body.dart';

class PlayScreen extends PositionComponent
    with HasGameReference<RealityTvGame> {
  static const _frameSize = 64.0;
  static const _columns = 2;
  static const _downRow = 2;
  static const _stepTime = 0.35;

  static const _topBarHeight = 140.0;
  static const _bottomBarHeight = 80.0;
  static const _pink = Color(0xFFFF1493);

  final List<Character> cast;

  PlayScreen({required this.cast});

  @override
  Future<void> onLoad() async {
    size = Vector2(1920, 1080);

    add(_Panel(
      position: Vector2.zero(),
      size: Vector2(1920, _topBarHeight),
      color: const Color(0xEE111111),
    ));

    add(_Panel(
      position: Vector2(0, 1080 - _bottomBarHeight),
      size: Vector2(1920, _bottomBarHeight),
      color: const Color(0xEE111111),
    ));

    add(_BorderLine(
      position: Vector2(0, _topBarHeight),
      size: Vector2(1920, 3),
      color: _pink,
    ));
    add(_BorderLine(
      position: Vector2(0, 1080 - _bottomBarHeight),
      size: Vector2(1920, 3),
      color: _pink,
    ));

    const charSlotWidth = 340.0;
    const ratingsWidth = 1920.0 - (charSlotWidth * 4);
    const spriteScale = 1.8;
    final spriteSize = Vector2.all(_frameSize * spriteScale);
    const spritePadLeft = 24.0;
    final textX = spritePadLeft + spriteSize.x + 8;

    for (int i = 0; i < cast.length && i < 4; i++) {
      final character = cast[i];
      final slotX = charSlotWidth * i;

      add(_Panel(
        position: Vector2(slotX, 0),
        size: Vector2(charSlotWidth, _topBarHeight),
        color: const Color(0xFF1A1A2E),
        borderColor: _pink,
        borderWidth: 2,
      ));

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
          size: spriteSize,
          position: Vector2(
            slotX + spritePadLeft,
            (_topBarHeight - spriteSize.y) / 2,
          ),
        ));
      }

      add(TextComponent(
        text: character.firstName,
        position: Vector2(slotX + textX, _topBarHeight / 2 - 26),
        anchor: Anchor.centerLeft,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontFamily: 'VT323',
            fontSize: 36,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ));

      add(TextComponent(
        text: character.attributes.map((a) => a.label).join('\n'),
        position: Vector2(slotX + textX, _topBarHeight / 2 + 16),
        anchor: Anchor.centerLeft,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontFamily: 'VT323',
            fontSize: 30,
            color: _pink,
          ),
        ),
      ));
    }

    const ratingsSlotX = charSlotWidth * 4;
    add(_Panel(
      position: Vector2(ratingsSlotX, 0),
      size: Vector2(ratingsWidth, _topBarHeight),
      color: const Color(0xFF1A1A2E),
      borderColor: _pink,
      borderWidth: 2,
    ));

    add(TextComponent(
      text: 'Ratings',
      position: Vector2(ratingsSlotX + ratingsWidth / 2, 20),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontFamily: 'CinzelDecorative',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: _pink,
        ),
      ),
    ));

    final coinPusher = CoinPusher()..position = Vector2(0, _topBarHeight + 3);
    game.activePusher = coinPusher;
    add(coinPusher);

    final statusText = 'S1E1: ${game.showName ?? ''}';
    add(TextComponent(
      text: statusText,
      position: Vector2(1900, 1080 - _bottomBarHeight / 2),
      anchor: Anchor.centerRight,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontFamily: 'VT323',
          fontSize: 36,
          color: Color(0xFFFFFFFF),
        ),
      ),
    ));

    add(_TokenQueueDisplay(
      coinPusher: coinPusher,
      position: Vector2(20, 1080 - _bottomBarHeight / 2),
    ));
  }
}

class _Panel extends PositionComponent {
  final Color color;
  final Color? borderColor;
  final double borderWidth;

  _Panel({
    required super.position,
    required super.size,
    required this.color,
    this.borderColor,
    this.borderWidth = 0,
  });

  @override
  void render(ui.Canvas canvas) {
    final rect = size.toRect();
    canvas.drawRect(rect, ui.Paint()..color = color);
    if (borderColor != null && borderWidth > 0) {
      canvas.drawRect(
        rect,
        ui.Paint()
          ..color = borderColor!
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = borderWidth,
      );
    }
  }
}

class _BorderLine extends PositionComponent {
  final Color color;

  _BorderLine({
    required super.position,
    required super.size,
    required this.color,
  });

  @override
  void render(ui.Canvas canvas) {
    canvas.drawRect(size.toRect(), ui.Paint()..color = color);
  }
}

class _TokenQueueDisplay extends PositionComponent {
  static const _tokenSize = 50.0;
  static const _spacing = 8.0;

  final CoinPusher coinPusher;

  _TokenQueueDisplay({
    required this.coinPusher,
    required super.position,
  }) {
    anchor = Anchor.centerLeft;
  }

  @override
  void render(ui.Canvas canvas) {
    final queue = coinPusher.tokenQueue;
    final coinImg = coinPusher.coinImage;
    final dramaImg = coinPusher.dramaImage;
    if (coinImg == null || dramaImg == null) return;

    final count = queue.length;

    for (int i = 0; i < count; i++) {
      final img = queue[i] == TokenType.coin ? coinImg : dramaImg;
      final x = i * (_tokenSize + _spacing);
      final y = -_tokenSize / 2;

      final srcRect = ui.Rect.fromLTWH(
          0, 0, img.width.toDouble(), img.height.toDouble());
      final dstRect = ui.Rect.fromLTWH(x, y, _tokenSize, _tokenSize);
      canvas.drawImageRect(
          img, srcRect, dstRect, ui.Paint()..filterQuality = ui.FilterQuality.low);
    }
  }
}
