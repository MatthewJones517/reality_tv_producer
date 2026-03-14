import 'dart:math';

import 'character.dart';
import 'game_config.dart';
import 'token_body.dart';

/// Manages the token launch queue and random token generation.
/// Pure logic -- no Flame or physics dependency.
class TokenQueue {
  final Random _random;
  final List<QueueToken> queue = [];

  /// Callback to read the current set of unlocked tokens.
  final Map<Attribute, int> Function() _unlockedTokens;

  TokenQueue({
    required Map<Attribute, int> Function() unlockedTokens,
    int size = CoinPusherConstants.queueSize,
    Random? random,
  })  : _unlockedTokens = unlockedTokens,
        _random = random ?? Random() {
    fill(size);
  }

  QueueToken _randomDramaOrAttribute() {
    final unlocked = _unlockedTokens();
    if (unlocked.isEmpty) return DramaQueueToken();
    final choices = <QueueToken>[
      DramaQueueToken(),
      ...unlocked.entries.map((e) => AttributeQueueToken(e.key, e.value)),
    ];
    return choices[_random.nextInt(choices.length)];
  }

  QueueToken randomToken() {
    final r = _random.nextDouble();
    if (r < SpawnConfig.coinSpawnRatio) return CoinQueueToken();
    return _randomDramaOrAttribute();
  }

  void fill([int targetSize = CoinPusherConstants.queueSize]) {
    while (queue.length < targetSize) {
      queue.insert(0, randomToken());
    }
  }

  /// Removes and returns the next token to shoot, then refills.
  QueueToken? pop() {
    if (queue.isEmpty) return null;
    final token = queue.removeLast();
    fill();
    return token;
  }
}

abstract final class CoinPusherConstants {
  static const queueSize = 6;
}
