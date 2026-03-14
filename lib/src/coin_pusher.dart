import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:forge2d/forge2d.dart' as f2d;

import 'audio_service.dart';
import 'character.dart';
import 'game.dart';
import 'game_config.dart';
import 'pusher_body.dart';
import 'scoring.dart';
import 'token_body.dart';
import 'token_queue.dart';

class CoinPusher extends PositionComponent
    with HasGameReference<RealityTvGame> {
  static const _scale = 0.01;

  static const fieldWidth = 1920.0;
  static const fieldHeight = 854.0;

  static const _tokenCount = 450;
  static const _pushDistance = 350.0;
  static const _pushSpeedPx = 120.0;
  static const _pusherStartX = 0.0;

  static const _shootSpeed = 800.0;
  static const _launcherRadius = 24.0;
  static const _pusherHalfW = 8.0;
  static const _launcherAngleSpeed = 3.0;
  static const _launcherAngleMin = -pi / 2 + 0.1;
  static const _launcherAngleMax = pi / 2 - 0.1;
  static const _outerDisableMargin = 100.0;

  static const _fireCooldown = 0.15;

  late final f2d.World _world;
  final _random = Random();
  final Set<TokenBody> _tokens = {};
  PusherBody? _pusher;
  ui.Image? _launcherImage;
  ui.Image? _edgeImage;
  ui.Image? _smokeImage;
  double _edgeWidth = 0;
  ui.Image? coinImage;
  ui.Image? dramaImage;
  ui.Image? tvImage;
  final Map<Attribute, ui.Image> _attributeImages = {};

  final List<TokenBody> _pendingRemoval = [];
  int coinsCollected = 0;
  double health = HealthConfig.initialHealth;
  double launcherAngle = 0;
  double _launcherCooldown = 0;

  late final ScoringEngine _scoring;
  late final TokenQueue _tokenQueue;

  List<QueueToken> get tokenQueue => _tokenQueue.queue;

  CoinPusher({int initialCoins = 0}) {
    size = Vector2(fieldWidth, fieldHeight);
    coinsCollected = initialCoins;
    _scoring = ScoringEngine();
  }

  // ─── Token Queue ─────────────────────────────────────────────────────────

  ui.Image? imageForQueueToken(QueueToken t) {
    return switch (t) {
      CoinQueueToken() => coinImage,
      DramaQueueToken() => dramaImage,
      AttributeQueueToken(attribute: final a) => _attributeImages[a],
    };
  }

  Future<void> convertDramaToAttribute(Attribute attr, int level) async {
    final dramaTokens = _tokens.where(
      (t) => t.type == TokenType.drama && t.attribute == null,
    );
    final list = dramaTokens.toList();
    final count = (list.length / SpawnConfig.dramaConvertFraction).floor();
    if (count <= 0) return;
    for (int i = 0; i < count; i++) {
      final token = list[i];
      await token.convertToAttribute(attr, level, (p) => game.images.load(p));
    }
  }

  // ─── Scoring ─────────────────────────────────────────────────────────────

  void onTokenHitDropZone(TokenBody token) {
    if (token.collected) return;
    token.collected = true;

    final result = _scoring.scoreToken(
      token,
      ownedPerks: game.ownedPerks,
      cast: game.currentCast,
    );

    if (result.isCoin) {
      AudioService.instance.playSfx(Sfx.coin);
    }
    if (result.healthDelta > 0) {
      health = (health + result.healthDelta).clamp(0, HealthConfig.maxHealth);
    }
    if (result.perkFlashName != null) {
      game.showPerkFlash(
        result.perkFlashName!,
        duration: result.perkFlashDuration,
      );
    }

    _pendingRemoval.add(token);
  }

  // ─── Launcher ────────────────────────────────────────────────────────────

  bool get launcherBlocked {
    final p = _pusher;
    if (p == null) return true;
    if (!p.hasCompletedFirstPush) return true;
    final pusherRightEdge = p.body.position.x / _scale + _pusherHalfW;
    final outerLimit = p.startX + _pushDistance - _outerDisableMargin;
    return pusherRightEdge >= outerLimit;
  }

  Vector2 get launcherPosition {
    return _pusher?.position.clone() ?? Vector2.zero();
  }

  void rotateLauncherUp(double dt) {
    launcherAngle = (launcherAngle + _launcherAngleSpeed * dt).clamp(
      _launcherAngleMin,
      _launcherAngleMax,
    );
  }

  void rotateLauncherDown(double dt) {
    launcherAngle = (launcherAngle - _launcherAngleSpeed * dt).clamp(
      _launcherAngleMin,
      _launcherAngleMax,
    );
  }

  void shoot() {
    if (!launcherBlocked && _launcherCooldown <= 0) {
      _launcherCooldown = _fireCooldown;
      _shootAt(launcherPosition.x, launcherPosition.y, launcherAngle);
    }
  }

  Future<void> _shootAt(double originX, double originY, double angle) async {
    final queueToken = _tokenQueue.pop();
    if (queueToken == null) return;

    final diameter = TokenBody.diameterForQueueToken(queueToken);
    final radius = (diameter / 2) * _scale;

    final offset = _launcherRadius + diameter / 2 + 4;
    final spawnX = originX + cos(angle) * offset;
    final spawnY = originY + sin(angle) * offset;

    final body = _createTokenBody(
      spawnX * _scale,
      spawnY * _scale,
      radius,
      bullet: true,
    );

    final vx = cos(angle) * _shootSpeed * _scale;
    final vy = sin(angle) * _shootSpeed * _scale;
    body.linearVelocity = f2d.Vector2(vx, vy);

    await _addTokenFromQueue(queueToken, body);
  }

  // ─── Physics Setup ───────────────────────────────────────────────────────

  @override
  Future<void> onLoad() async {
    _launcherImage = await game.images.load(Assets.launcher);
    _edgeImage = await game.images.load(Assets.edge);
    if (_edgeImage != null) {
      final img = _edgeImage!;
      _edgeWidth = fieldHeight * (img.width / img.height);
    }
    coinImage = await game.images.load(Assets.coin);
    dramaImage = await game.images.load(Assets.dramaChip);
    for (final attr in Attribute.values) {
      _attributeImages[attr] = await game.images.load(Assets.chipPath(attr));
    }
    _smokeImage = await game.images.load(Assets.smoke);
    tvImage = await game.images.load(Assets.tvNoAntenna);
    final pusherImage = await game.images.load(Assets.pusher);

    _tokenQueue = TokenQueue(unlockedTokens: () => game.unlockedTokens);

    f2d.velocityIterations = 4;
    _world = f2d.World(f2d.Vector2.zero());
    _world.setContactListener(_ContactListener(this));

    _createWalls();
    _createDropZone();
    await _createPusher(pusherImage);
    await _spawnTokens();
  }

  void _createWalls() {
    final w = fieldWidth * _scale;
    final h = fieldHeight * _scale;

    _createEdge(f2d.Vector2(0, 0), f2d.Vector2(w, 0));
    _createEdge(f2d.Vector2(0, h), f2d.Vector2(w, h));
    _createEdge(f2d.Vector2(0, 0), f2d.Vector2(0, h));
  }

  void _createEdge(f2d.Vector2 v1, f2d.Vector2 v2) {
    final bodyDef = f2d.BodyDef(type: f2d.BodyType.static);
    final body = _world.createBody(bodyDef);
    final shape = f2d.EdgeShape()..set(v1, v2);
    body.createFixture(f2d.FixtureDef(shape, friction: 0.3));
  }

  void _createDropZone() {
    final h = fieldHeight * _scale;
    final dropX = _edgeWidth > 0
        ? (fieldWidth - _edgeWidth / 2) * _scale
        : fieldWidth * _scale;
    final zoneWidth = 3 * (_edgeWidth > 0 ? _edgeWidth : 50) * _scale;
    final halfW = zoneWidth / 2;
    final halfH = h / 2;
    final centerX = dropX - halfW;
    final centerY = halfH;

    final bodyDef = f2d.BodyDef(
      type: f2d.BodyType.static,
      position: f2d.Vector2(centerX, centerY),
    );
    final body = _world.createBody(bodyDef);
    final shape = f2d.PolygonShape()..setAsBoxXY(halfW, halfH);
    final fixtureDef = f2d.FixtureDef(shape)..isSensor = true;
    body.createFixture(fixtureDef);
    body.userData = 'dropZone';
  }

  Future<void> _createPusher(ui.Image pusherImage) async {
    final halfW = 8.0 * _scale;
    final halfH = (fieldHeight / 2) * _scale;
    final centerY = halfH;
    final startPhysX = _pusherStartX * _scale + halfW;

    final bodyDef = f2d.BodyDef(
      type: f2d.BodyType.kinematic,
      position: f2d.Vector2(startPhysX, centerY),
    );
    final body = _world.createBody(bodyDef);
    final shape = f2d.PolygonShape()..setAsBoxXY(halfW, halfH);
    body.createFixture(f2d.FixtureDef(shape, friction: 0.5));

    _pusher = PusherBody(
      body: body,
      physScale: _scale,
      fieldHeight: fieldHeight,
      pushDistance: _pushDistance,
      pushSpeed: _pushSpeedPx * _scale,
      startX: _pusherStartX + 8,
      image: pusherImage,
    );
    body.linearVelocity = f2d.Vector2(_pushSpeedPx * _scale, 0);
    add(_pusher!);
    add(_LauncherOverlay(this)..priority = 100);
  }

  f2d.Body _createTokenBody(
    double physX,
    double physY,
    double radius, {
    bool bullet = false,
  }) {
    final bodyDef = f2d.BodyDef(
      type: f2d.BodyType.dynamic,
      position: f2d.Vector2(physX, physY),
      linearDamping: 2.0,
      angularDamping: 1.0,
      bullet: bullet,
    );
    final body = _world.createBody(bodyDef);
    final shape = f2d.CircleShape()..radius = radius;
    body.createFixture(
      f2d.FixtureDef(shape, friction: 0.3, restitution: 0.2, density: 1.0),
    );
    return body;
  }

  Future<void> _addTokenFromQueue(QueueToken queueToken, f2d.Body body) async {
    final (type, attr, level) = switch (queueToken) {
      CoinQueueToken() => (TokenType.coin, null, 1),
      DramaQueueToken() => (TokenType.drama, null, 1),
      AttributeQueueToken(:final attribute, :final level) => (
        TokenType.drama,
        attribute,
        level,
      ),
    };
    final token = TokenBody(
      type: type,
      body: body,
      physScale: _scale,
      attribute: attr,
      attributeLevel: level,
    );
    await token.loadSprite((path) => game.images.load(path));
    _tokens.add(token);
    add(token);
  }

  Future<void> _spawnTokens() async {
    for (int i = 0; i < _tokenCount; i++) {
      final queueToken = _tokenQueue.randomToken();
      final diameter = TokenBody.diameterForQueueToken(queueToken);
      final radius = (diameter / 2) * _scale;

      final margin = diameter / 2 + 10;
      final minX = margin;
      final maxX = fieldWidth - margin;
      final minY = margin;
      final maxY = fieldHeight - margin;

      final px = minX + _random.nextDouble() * (maxX - minX);
      final py = minY + _random.nextDouble() * (maxY - minY);

      final body = _createTokenBody(px * _scale, py * _scale, radius);
      await _addTokenFromQueue(queueToken, body);
    }
  }

  // ─── Effects ─────────────────────────────────────────────────────────────

  void _spawnSmoke(Vector2 position, double tokenSize) {
    final img = _smokeImage;
    if (img == null) return;

    final sheet = SpriteSheet(image: img, srcSize: Vector2(32, 32));
    final animation = sheet.createAnimation(
      row: 0,
      stepTime: 0.05,
      loop: false,
      from: 0,
      to: 7,
    );

    add(
      SpriteAnimationComponent(
        animation: animation,
        size: Vector2.all(tokenSize),
        position: position,
        anchor: Anchor.center,
        removeOnFinish: true,
      ),
    );
  }

  // ─── Game Loop ───────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);

    final drainRate = _scoring.computeDrainRate(game.currentSeason);
    health = (health - dt * drainRate).clamp(0, HealthConfig.maxHealth);
    if (health <= 0) game.triggerGameOver();

    if (_launcherCooldown > 0) _launcherCooldown -= dt;
    _world.stepDt(dt);

    for (final token in _pendingRemoval) {
      if (token.type == TokenType.coin) coinsCollected++;
      if (token.type == TokenType.drama) {
        _spawnSmoke(token.position, token.size.x);
      }
      _world.destroyBody(token.body);
      _tokens.remove(token);
      token.removeFromParent();
    }
    _pendingRemoval.clear();
  }

  // ─── Rendering ───────────────────────────────────────────────────────────

  static const _bgColor = 0xFF696a6a;

  @override
  void render(ui.Canvas canvas) {
    canvas.clipRect(size.toRect());
    canvas.drawRect(
      size.toRect(),
      ui.Paint()..color = const ui.Color(_bgColor),
    );
    super.render(canvas);
    _renderEdge(canvas);
  }

  void _renderEdge(ui.Canvas canvas) {
    final zoneWidth = 3.0 * (_edgeWidth > 0 ? _edgeWidth : 50.0);
    const extraBlackWidth = 80.0;

    final img = _edgeImage;
    if (img != null && _edgeWidth > 0) {
      final graphicX = fieldWidth - zoneWidth - extraBlackWidth;
      final srcRect = ui.Rect.fromLTWH(
        0,
        0,
        img.width.toDouble(),
        img.height.toDouble(),
      );
      final dstRect = ui.Rect.fromLTWH(graphicX, 0, zoneWidth, fieldHeight);
      canvas.drawImageRect(
        img,
        srcRect,
        dstRect,
        ui.Paint()..filterQuality = ui.FilterQuality.low,
      );
      // Overlap by 2px to avoid gray seam from sub-pixel gap or edge image
      canvas.drawRect(
        ui.Rect.fromLTWH(
          fieldWidth - extraBlackWidth - 2,
          0,
          extraBlackWidth + 2,
          fieldHeight,
        ),
        ui.Paint()..color = const ui.Color(0xFF000000),
      );
    } else {
      canvas.drawRect(
        ui.Rect.fromLTWH(
          fieldWidth - zoneWidth - extraBlackWidth,
          0,
          zoneWidth + extraBlackWidth,
          fieldHeight,
        ),
        ui.Paint()..color = const ui.Color(0xFF000000),
      );
    }
  }
}

class _LauncherOverlay extends PositionComponent {
  static const _launcherDrawSize = 160.0;

  final CoinPusher pusher;

  _LauncherOverlay(this.pusher);

  @override
  void render(ui.Canvas canvas) {
    final img = pusher._launcherImage;
    if (img == null) return;

    final pos = pusher.launcherPosition;
    _drawLauncher(
      canvas,
      pos.x,
      pos.y,
      pusher.launcherAngle,
      pusher.launcherBlocked,
      img,
    );
  }

  void _drawLauncher(
    ui.Canvas canvas,
    double x,
    double y,
    double angle,
    bool disabled,
    ui.Image img,
  ) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);

    final srcRect = ui.Rect.fromLTWH(
      0,
      0,
      img.width.toDouble(),
      img.height.toDouble(),
    );
    final aspect = img.width / img.height;
    final drawW = _launcherDrawSize;
    final drawH = drawW / aspect;
    final dstRect = ui.Rect.fromCenter(
      center: ui.Offset.zero,
      width: drawW,
      height: drawH,
    );

    final paint = ui.Paint()..filterQuality = ui.FilterQuality.low;
    if (disabled) {
      paint.colorFilter = const ui.ColorFilter.mode(
        ui.Color(0x88000000),
        ui.BlendMode.srcATop,
      );
    }

    canvas.drawImageRect(img, srcRect, dstRect, paint);
    canvas.restore();
  }
}

class _ContactListener extends f2d.ContactListener {
  final CoinPusher pusher;

  _ContactListener(this.pusher);

  @override
  void beginContact(f2d.Contact contact) {
    final a = contact.fixtureA.body.userData;
    final b = contact.fixtureB.body.userData;

    if (a == 'dropZone' && b is TokenBody) {
      pusher.onTokenHitDropZone(b);
    } else if (b == 'dropZone' && a is TokenBody) {
      pusher.onTokenHitDropZone(a);
    }
  }
}
