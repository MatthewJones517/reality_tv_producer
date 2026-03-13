import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/painting.dart';

import 'character.dart';
import 'coin_pusher.dart';
import 'game.dart';

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
  final int initialCoins;

  PlayScreen({required this.cast, this.initialCoins = 0});

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

    final coinPusher = CoinPusher(initialCoins: initialCoins)
      ..position = Vector2(0, _topBarHeight + 3);
    game.activePusher = coinPusher;
    add(coinPusher);

    add(_HealthBarDisplay(
      coinPusher: coinPusher,
      position: Vector2(ratingsSlotX + ratingsWidth / 2, 85),
    ));

    add(_CoinCounterDisplay(
      coinPusher: coinPusher,
      position: Vector2(1150, 1080 - _bottomBarHeight / 2),
    ));

    add(_ShowInfoDisplay(
      game: game,
      coinPusher: coinPusher,
      position: Vector2(1900, 1080 - _bottomBarHeight / 2),
    ));

    add(_TokenQueueDisplay(
      coinPusher: coinPusher,
      position: Vector2(20, 1080 - _bottomBarHeight / 2),
    ));

    const queueWidth = 6 * (50 + 8);
    add(_SkillStopMeterDisplay(
      coinPusher: coinPusher,
      position: Vector2(20 + queueWidth + 24, 1080 - _bottomBarHeight / 2),
    ));
  }
}

class _HealthBarDisplay extends PositionComponent {
  static const _barWidth = 400.0;
  static const _barHeight = 24.0;
  static const _green = Color(0xFF22C55E);
  static const _yellow = Color(0xFFEAB308);
  static const _red = Color(0xFFEF4444);
  static const _bgColor = Color(0xFF333333);
  static const _blinkThreshold = 15;
  static const _blinkCycle = 0.15;

  final CoinPusher coinPusher;
  double _blinkTime = 0;

  _HealthBarDisplay({
    required this.coinPusher,
    required super.position,
  }) {
    anchor = Anchor.center;
  }

  Color _colorForHealth(double health) {
    if (health > _blinkThreshold) {
      if (health >= 80) return _green;
      if (health >= 35) return _yellow;
      return _red;
    }
    final phase = (_blinkTime % _blinkCycle) / _blinkCycle;
    if (phase < 1 / 3) return _red;
    if (phase < 2 / 3) return _yellow;
    return _green;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (coinPusher.health <= _blinkThreshold) _blinkTime += dt;
  }

  @override
  void render(ui.Canvas canvas) {
    final h = coinPusher.health.clamp(0.0, 100.0);
    final fillFraction = h / 100;

    final barRect = ui.Rect.fromCenter(
      center: ui.Offset.zero,
      width: _barWidth,
      height: _barHeight,
    );
    final radius = ui.Radius.circular(_barHeight / 2);

    canvas.drawRRect(
      ui.RRect.fromRectAndRadius(barRect, radius),
      ui.Paint()..color = _bgColor,
    );

    if (fillFraction > 0) {
      final fillWidth = _barWidth * fillFraction;
      final fillRect = ui.Rect.fromLTRB(
        -_barWidth / 2,
        -_barHeight / 2,
        -_barWidth / 2 + fillWidth,
        _barHeight / 2,
      );
      canvas.drawRRect(
        ui.RRect.fromRectAndRadius(fillRect, radius),
        ui.Paint()..color = _colorForHealth(h),
      );
    }
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

class _CoinCounterDisplay extends PositionComponent {
  static const _iconSize = 40.0;
  static const _gap = 12.0;

  final CoinPusher coinPusher;
  final _textPaint = TextPaint(
    style: const TextStyle(
      fontFamily: 'VT323',
      fontSize: 36,
      color: Color(0xFFFFFFFF),
    ),
  );

  _CoinCounterDisplay({
    required this.coinPusher,
    required super.position,
  }) {
    anchor = Anchor.centerRight;
  }

  @override
  void render(ui.Canvas canvas) {
    final coinImg = coinPusher.coinImage;
    if (coinImg == null) return;

    final countStr = '${coinPusher.coinsCollected}';
    final countWidth = _textPaint.toTextPainter(countStr).width;
    final countRight = 0.0;
    final coinRight = -countWidth - _gap;

    final paint = ui.Paint()..filterQuality = ui.FilterQuality.low;

    canvas.drawImageRect(
      coinImg,
      ui.Rect.fromLTWH(0, 0, coinImg.width.toDouble(), coinImg.height.toDouble()),
      ui.Rect.fromCenter(
        center: ui.Offset(coinRight - _iconSize / 2, 0),
        width: _iconSize,
        height: _iconSize,
      ),
      paint,
    );

    _textPaint.render(
      canvas,
      countStr,
      Vector2(countRight, 0),
      anchor: Anchor.centerRight,
    );
  }
}

class _ShowInfoDisplay extends PositionComponent {
  static const _iconSize = 40.0;
  static const _gap = 8.0;

  final RealityTvGame game;
  final CoinPusher coinPusher;
  final _textPaint = TextPaint(
    style: const TextStyle(
      fontFamily: 'VT323',
      fontSize: 36,
      color: Color(0xFFFFFFFF),
    ),
  );

  _ShowInfoDisplay({
    required this.game,
    required this.coinPusher,
    required super.position,
  }) {
    anchor = Anchor.centerRight;
  }

  @override
  void render(ui.Canvas canvas) {
    final tvImg = coinPusher.tvImage;
    final text =
        'S${game.currentSeason}E${game.currentEpisode}: ${game.showName ?? ''}';
    final textWidth = _textPaint.toTextPainter(text).width;

    final textRight = 0.0;
    final tvRight = -textWidth - _gap;

    if (tvImg != null) {
      canvas.drawImageRect(
        tvImg,
        ui.Rect.fromLTWH(0, 0, tvImg.width.toDouble(), tvImg.height.toDouble()),
        ui.Rect.fromCenter(
          center: ui.Offset(tvRight - _iconSize / 2, 0),
          width: _iconSize,
          height: _iconSize,
        ),
        ui.Paint()..filterQuality = ui.FilterQuality.low,
      );
    }

    _textPaint.render(
      canvas,
      text,
      Vector2(textRight, 0),
      anchor: Anchor.centerRight,
    );
  }
}

class _SkillStopMeterDisplay extends PositionComponent {
  static const _barWidth = 160.0;
  static const _barHeight = 40.0;

  final CoinPusher coinPusher;

  _SkillStopMeterDisplay({
    required this.coinPusher,
    required super.position,
  }) {
    anchor = Anchor.centerLeft;
  }

  @override
  void render(ui.Canvas canvas) {
    final charge = coinPusher.skillStopCharge.clamp(0.0, 1.0);
    final barRect = ui.Rect.fromLTWH(0, -_barHeight / 2, _barWidth, _barHeight);
    final radius = ui.Radius.circular(_barHeight / 2);

    canvas.drawRRect(
      ui.RRect.fromRectAndRadius(barRect, radius),
      ui.Paint()..color = const ui.Color(0xFF333333),
    );

    if (charge > 0) {
      final fillWidth = _barWidth * charge;
      final fillRect = ui.Rect.fromLTWH(0, -_barHeight / 2, fillWidth, _barHeight);
      canvas.drawRRect(
        ui.RRect.fromRectAndRadius(fillRect, radius),
        ui.Paint()..color = const ui.Color(0xFF87CEEB),
      );
    }
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
    final count = queue.length;

    for (int i = 0; i < count; i++) {
      final img = coinPusher.imageForQueueToken(queue[i]);
      if (img == null) continue;
      final x = i * (_tokenSize + _spacing);
      final y = -_tokenSize / 2;

      final srcRect = ui.Rect.fromLTWH(
          0, 0, img.width.toDouble(), img.height.toDouble());
      final dstRect = ui.Rect.fromLTWH(x, y, _tokenSize, _tokenSize);
      canvas.drawImageRect(img, srcRect, dstRect,
          ui.Paint()..filterQuality = ui.FilterQuality.low);
    }
  }
}
