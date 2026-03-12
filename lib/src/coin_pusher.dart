import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:forge2d/forge2d.dart' as f2d;

import 'character.dart';
import 'game.dart';
import 'pusher_body.dart';
import 'token_body.dart';

class CoinPusher extends PositionComponent
    with HasGameReference<RealityTvGame> {
  static const _scale = 0.01;

  static const fieldWidth = 1920.0;
  static const fieldHeight = 854.0;

  static const _tokenCount = 550;
  static const _pushDistance = 350.0;
  static const _pushSpeedPx = 120.0;
  static const _pusherStartX = 0.0;

  static const _shootSpeed = 800.0;
  static const _launcherRadius = 24.0;
  static const _pusherHalfW = 8.0;
  static const _launcherAngleSpeed = 3.0;
  static const _launcherAngleMin = -pi / 2 + 0.1;
  static const _launcherAngleMax = pi / 2 - 0.1;
  static const _outerDisableMargin = 40.0;

  static const queueSize = 6;

  late final f2d.World _world;
  final _random = Random();
  final List<TokenBody> _tokens = [];
  PusherBody? _pusher;
  ui.Image? _launcherImage;
  ui.Image? _edgeImage;
  ui.Image? _smokeImage;
  double _edgeWidth = 0;
  ui.Image? coinImage;
  ui.Image? dramaImage;
  ui.Image? tvImage;
  final Map<Attribute, ui.Image> _attributeImages = {};

  static const _fireCooldown = 0.05;

  final List<TokenBody> _pendingRemoval = [];
  final List<QueueToken> tokenQueue = [];
  int coinsCollected = 0;
  double health = 100.0;
  double launcherAngle = 0;
  double _launcherCooldown = 0;

  CoinPusher({int initialCoins = 0}) {
    size = Vector2(fieldWidth, fieldHeight);
    coinsCollected = initialCoins;
  }

  QueueToken _randomDramaOrAttribute() {
    final unlocked = game.unlockedTokens;
    if (unlocked.isEmpty) return DramaQueueToken();
    final choices = <QueueToken>[DramaQueueToken()]
      ..addAll(unlocked.entries
          .map((e) => AttributeQueueToken(e.key, e.value)));
    return choices[_random.nextInt(choices.length)];
  }

  QueueToken _randomQueueToken() {
    final r = _random.nextDouble();
    if (r < 0.90) return CoinQueueToken();
    return _randomDramaOrAttribute();
  }

  /// 90% coin, 10% drama/attribute for board spawn.
  QueueToken _randomSpawnToken() {
    final r = _random.nextDouble();
    if (r < 0.90) return CoinQueueToken();
    return _randomDramaOrAttribute();
  }

  void _fillQueue() {
    while (tokenQueue.length < queueSize) {
      tokenQueue.insert(0, _randomQueueToken());
    }
  }

  @override
  Future<void> onLoad() async {
    _launcherImage = await game.images.load('assets/playfield/launcher.png');
    _edgeImage = await game.images.load('assets/playfield/edge.png');
    if (_edgeImage != null) {
      final img = _edgeImage!;
      _edgeWidth = fieldHeight * (img.width / img.height);
    }
    coinImage = await game.images.load('assets/playfield/coin.png');
    dramaImage = await game.images.load('assets/playfield/Drama_Chip.png');
    for (final attr in Attribute.values) {
      final name =
          '${attr.name[0].toUpperCase()}${attr.name.substring(1)}_Chip.png';
      _attributeImages[attr] =
          await game.images.load('assets/playfield/$name');
    }
    _smokeImage = await game.images.load('assets/playfield/smoke.png');
    tvImage = await game.images.load('assets/playfield/tv_no_antenna.png');
    final pusherImage = await game.images.load('assets/playfield/pusher.png');

    _fillQueue();

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

    final bodyDef = f2d.BodyDef(type: f2d.BodyType.static);
    final body = _world.createBody(bodyDef);
    final shape = f2d.EdgeShape()..set(f2d.Vector2(dropX, 0), f2d.Vector2(dropX, h));
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

  Future<void> _spawnTokens() async {
    for (int i = 0; i < _tokenCount; i++) {
      final queueToken = _randomSpawnToken();
      final diameter = TokenBody.diameterForQueueToken(queueToken);
      final radius = (diameter / 2) * _scale;

      final margin = diameter / 2 + 10;
      final minX = margin;
      final maxX = fieldWidth - margin;
      final minY = margin;
      final maxY = fieldHeight - margin;

      final px = minX + _random.nextDouble() * (maxX - minX);
      final py = minY + _random.nextDouble() * (maxY - minY);

      final bodyDef = f2d.BodyDef(
        type: f2d.BodyType.dynamic,
        position: f2d.Vector2(px * _scale, py * _scale),
        linearDamping: 2.0,
        angularDamping: 1.0,
      );
      final body = _world.createBody(bodyDef);
      final shape = f2d.CircleShape()..radius = radius;
      body.createFixture(f2d.FixtureDef(
        shape,
        friction: 0.3,
        restitution: 0.2,
        density: 1.0,
      ));

      final (type, attr, level) = switch (queueToken) {
        CoinQueueToken() => (TokenType.coin, null, 1),
        DramaQueueToken() => (TokenType.drama, null, 1),
        AttributeQueueToken(:final attribute, :final level) =>
          (TokenType.drama, attribute, level),
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
  }

  void onTokenHitDropZone(TokenBody token) {
    if (!token.collected) {
      token.collected = true;
      if (token.type == TokenType.coin) {
        // Handled in update (coinsCollected)
      } else if (token.isAttributeToken && token.attribute != null) {
        final matchCount = game.currentCast
            .where((c) => c.attributes.contains(token.attribute))
            .length;
        final perChar = token.attributeLevel;
        final multiplier = 1 + matchCount * perChar;
        health = (health + 5 * multiplier).clamp(0, 100);
      } else {
        health = (health + 5).clamp(0, 100);
      }
      _pendingRemoval.add(token);
    }
  }

  void _spawnSmoke(Vector2 position, double tokenSize) {
    final img = _smokeImage;
    if (img == null) return;

    final sheet = SpriteSheet(
      image: img,
      srcSize: Vector2(32, 32),
    );
    final animation = sheet.createAnimation(
      row: 0,
      stepTime: 0.05,
      loop: false,
      from: 0,
      to: 7,
    );

    add(SpriteAnimationComponent(
      animation: animation,
      size: Vector2.all(tokenSize),
      position: position,
      anchor: Anchor.center,
      removeOnFinish: true,
    ));
  }

  bool get launcherBlocked {
    if (_pusher == null) return true;
    if (!_pusher!.hasCompletedFirstPush) return true;
    final pusherRightEdge =
        _pusher!.body.position.x / _scale + _pusherHalfW;
    final outerLimit = _pusher!.startX + _pushDistance - _outerDisableMargin;
    return pusherRightEdge >= outerLimit;
  }

  ui.Image? imageForQueueToken(QueueToken t) {
    return switch (t) {
      CoinQueueToken() => coinImage,
      DramaQueueToken() => dramaImage,
      AttributeQueueToken(attribute: final a) => _attributeImages[a],
    };
  }

  Vector2 get launcherPosition {
    if (_pusher == null) return Vector2.zero();
    return _pusher!.position.clone();
  }

  void rotateLauncherUp(double dt) {
    launcherAngle = (launcherAngle + _launcherAngleSpeed * dt)
        .clamp(_launcherAngleMin, _launcherAngleMax);
  }

  void rotateLauncherDown(double dt) {
    launcherAngle = (launcherAngle - _launcherAngleSpeed * dt)
        .clamp(_launcherAngleMin, _launcherAngleMax);
  }

  void shoot() {
    if (!launcherBlocked && _launcherCooldown <= 0) {
      _launcherCooldown = _fireCooldown;
      _shootAt(launcherPosition.x, launcherPosition.y, launcherAngle);
    }
  }

  Future<void> _shootAt(double originX, double originY, double angle) async {
    if (tokenQueue.isEmpty) return;
    final queueToken = tokenQueue.removeLast();
    _fillQueue();
    final diameter = TokenBody.diameterForQueueToken(queueToken);
    final radius = (diameter / 2) * _scale;

    final offset = _launcherRadius + diameter / 2 + 4;
    final spawnX = originX + cos(angle) * offset;
    final spawnY = originY + sin(angle) * offset;

    final bodyDef = f2d.BodyDef(
      type: f2d.BodyType.dynamic,
      position: f2d.Vector2(spawnX * _scale, spawnY * _scale),
      linearDamping: 2.0,
      angularDamping: 1.0,
      bullet: true,
    );
    final body = _world.createBody(bodyDef);
    final shape = f2d.CircleShape()..radius = radius;
    body.createFixture(f2d.FixtureDef(
      shape,
      friction: 0.3,
      restitution: 0.2,
      density: 1.0,
    ));

    final vx = cos(angle) * _shootSpeed * _scale;
    final vy = sin(angle) * _shootSpeed * _scale;
    body.linearVelocity = f2d.Vector2(vx, vy);

    final (type, attr, level) = switch (queueToken) {
      CoinQueueToken() => (TokenType.coin, null, 1),
      DramaQueueToken() => (TokenType.drama, null, 1),
      AttributeQueueToken(:final attribute, :final level) =>
        (TokenType.drama, attribute, level),
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

  @override
  void update(double dt) {
    super.update(dt);
    health = (health - dt * 3).clamp(0, 100);
    if (health <= 0) game.triggerGameOver();
    if (_launcherCooldown > 0) _launcherCooldown -= dt;
    _world.stepDt(dt);

    for (final token in _pendingRemoval) {
      if (token.type == TokenType.coin) coinsCollected++;
      _spawnSmoke(token.position, token.size.x);
      _world.destroyBody(token.body);
      _tokens.remove(token);
      token.removeFromParent();
    }
    _pendingRemoval.clear();
  }

  static const _bgColor = 0xFF696a6a;

  @override
  void render(ui.Canvas canvas) {
    canvas.clipRect(size.toRect());
    canvas.drawRect(size.toRect(), ui.Paint()..color = const ui.Color(_bgColor));
    super.render(canvas);
    _renderEdge(canvas);
  }

  void _renderEdge(ui.Canvas canvas) {
    final img = _edgeImage;
    if (img == null || _edgeWidth <= 0) return;

    final x = fieldWidth - _edgeWidth;
    final srcRect = ui.Rect.fromLTWH(
        0, 0, img.width.toDouble(), img.height.toDouble());
    final dstRect = ui.Rect.fromLTWH(x, 0, _edgeWidth, fieldHeight);
    canvas.drawImageRect(
        img, srcRect, dstRect, ui.Paint()..filterQuality = ui.FilterQuality.low);
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
        canvas, pos.x, pos.y, pusher.launcherAngle, pusher.launcherBlocked, img);
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
        0, 0, img.width.toDouble(), img.height.toDouble());
    final aspect = img.width / img.height;
    final drawW = _launcherDrawSize;
    final drawH = drawW / aspect;
    final dstRect = ui.Rect.fromCenter(
        center: ui.Offset.zero, width: drawW, height: drawH);

    final paint = ui.Paint()..filterQuality = ui.FilterQuality.low;
    if (disabled) {
      paint.colorFilter = const ui.ColorFilter.mode(
          ui.Color(0x88000000), ui.BlendMode.srcATop);
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
