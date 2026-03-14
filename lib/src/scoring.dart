import 'dart:math';

import 'character.dart';
import 'game_config.dart';
import 'perk.dart';
import 'token_body.dart';

/// Result of processing a single token collection.
class CollectionResult {
  final double healthDelta;
  final bool isCoin;
  final String? perkFlashName;
  final double perkFlashDuration;

  const CollectionResult({
    required this.healthDelta,
    this.isCoin = false,
    this.perkFlashName,
    this.perkFlashDuration = 1.0,
  });
}

/// Pure-logic scoring engine. Computes health drain, token collection
/// bonuses, and perk interactions without any Flame dependency.
class ScoringEngine {
  final Random _random;

  ScoringEngine([Random? random]) : _random = random ?? Random();

  double computeDrainRate(int season) {
    final multiplier = season <= HealthConfig.drainEarlySeasons
        ? pow(HealthConfig.drainEarlyBase, season - 1)
        : pow(HealthConfig.drainEarlyBase, HealthConfig.drainEarlySeasons - 1) *
            pow(HealthConfig.drainLateBase,
                season - HealthConfig.drainEarlySeasons);
    return HealthConfig.baseDrainRate * multiplier;
  }

  /// Returns (extra match count from doubler perks, perk to flash).
  (int, Perk?) attributeDoublerBonus(
    Attribute tokenAttr, {
    required Set<Perk> ownedPerks,
    required List<Character> cast,
  }) {
    var extra = 0;
    Perk? flash;

    for (final entry in perkDoublerMappings.entries) {
      if (!ownedPerks.contains(entry.key)) continue;
      for (final mapping in entry.value) {
        if (tokenAttr != mapping.trigger) continue;
        final n =
            cast.where((c) => c.attributes.contains(mapping.bonus)).length;
        extra += n;
        if (n > 0) flash ??= entry.key;
      }
    }

    return (extra, flash);
  }

  CollectionResult scoreToken(
    TokenBody token, {
    required Set<Perk> ownedPerks,
    required List<Character> cast,
  }) {
    if (token.type == TokenType.coin) {
      final bonus = ownedPerks.contains(Perk.marketingBudget)
          ? HealthConfig.marketingBudgetCoinBonus
          : 0.0;
      return CollectionResult(healthDelta: bonus, isCoin: true);
    }

    if (token.isAttributeToken && token.attribute != null) {
      final matchCount =
          cast.where((c) => c.attributes.contains(token.attribute)).length;
      final perChar = token.attributeLevel;
      final (doublerCount, _) = attributeDoublerBonus(
        token.attribute!,
        ownedPerks: ownedPerks,
        cast: cast,
      );
      final effectiveMatch = matchCount + doublerCount;
      final multiplier = 1 + effectiveMatch * perChar;
      var gain = HealthConfig.baseHealthGain * multiplier;
      return _withMemeLord(gain, ownedPerks);
    }

    return _withMemeLord(HealthConfig.baseHealthGain, ownedPerks);
  }

  CollectionResult _withMemeLord(double gain, Set<Perk> ownedPerks) {
    if (ownedPerks.contains(Perk.memeLord) &&
        _random.nextDouble() < HealthConfig.memeLordChance) {
      return CollectionResult(
        healthDelta: gain * HealthConfig.memeLordMultiplier,
        perkFlashName: Perk.memeLord.label,
        perkFlashDuration: HealthConfig.memeLordFlashDuration,
      );
    }
    return CollectionResult(healthDelta: gain);
  }
}
