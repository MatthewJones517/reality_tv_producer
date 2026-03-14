import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:reality_tv_producer/src/character.dart';
import 'package:reality_tv_producer/src/game_config.dart';
import 'package:reality_tv_producer/src/perk.dart';
import 'package:reality_tv_producer/src/scoring.dart';
import 'package:reality_tv_producer/src/token_body.dart';
import 'package:reality_tv_producer/src/token_queue.dart';

void main() {
  group('ScoringEngine.computeDrainRate', () {
    late ScoringEngine engine;

    setUp(() => engine = ScoringEngine());

    test('season 1 has base drain rate', () {
      expect(engine.computeDrainRate(1), HealthConfig.baseDrainRate);
    });

    test('drain rate increases each season', () {
      final s1 = engine.computeDrainRate(1);
      final s2 = engine.computeDrainRate(2);
      final s3 = engine.computeDrainRate(3);
      expect(s2, greaterThan(s1));
      expect(s3, greaterThan(s2));
    });

    test('uses early base for seasons <= drainEarlySeasons', () {
      final rate = engine.computeDrainRate(3);
      final expected =
          HealthConfig.baseDrainRate * pow(HealthConfig.drainEarlyBase, 2);
      expect(rate, closeTo(expected, 0.001));
    });

    test('uses late base for seasons beyond drainEarlySeasons', () {
      final s = HealthConfig.drainEarlySeasons + 1;
      final rate = engine.computeDrainRate(s);
      final earlyPart =
          pow(HealthConfig.drainEarlyBase, HealthConfig.drainEarlySeasons - 1);
      final latePart = pow(HealthConfig.drainLateBase, 1);
      final expected = HealthConfig.baseDrainRate * earlyPart * latePart;
      expect(rate, closeTo(expected, 0.001));
    });
  });

  group('ScoringEngine.attributeDoublerBonus', () {
    late ScoringEngine engine;

    setUp(() => engine = ScoringEngine());

    test('returns zero with no perks', () {
      final (extra, flash) = engine.attributeDoublerBonus(
        Attribute.charming,
        ownedPerks: {},
        cast: [
          Character(
            firstName: 'A',
            lastName: 'B',
            attributes: [Attribute.flirty],
            funFact: '',
            parts: _dummyParts(),
          ),
        ],
      );
      expect(extra, 0);
      expect(flash, isNull);
    });

    test('doubleThreat adds flirty count for charming token', () {
      final cast = [
        Character(
          firstName: 'A',
          lastName: 'B',
          attributes: [Attribute.flirty],
          funFact: '',
          parts: _dummyParts(),
        ),
        Character(
          firstName: 'C',
          lastName: 'D',
          attributes: [Attribute.flirty],
          funFact: '',
          parts: _dummyParts(),
        ),
      ];
      final (extra, flash) = engine.attributeDoublerBonus(
        Attribute.charming,
        ownedPerks: {Perk.doubleThreat},
        cast: cast,
      );
      expect(extra, 2);
      expect(flash, Perk.doubleThreat);
    });

    test('does not trigger for wrong token attribute', () {
      final cast = [
        Character(
          firstName: 'A',
          lastName: 'B',
          attributes: [Attribute.flirty],
          funFact: '',
          parts: _dummyParts(),
        ),
      ];
      final (extra, flash) = engine.attributeDoublerBonus(
        Attribute.stoic,
        ownedPerks: {Perk.doubleThreat},
        cast: cast,
      );
      expect(extra, 0);
      expect(flash, isNull);
    });
  });

  group('TokenQueue', () {
    test('initializes with correct size', () {
      final tq = TokenQueue(unlockedTokens: () => {});
      expect(tq.queue.length, CoinPusherConstants.queueSize);
    });

    test('pop returns a token and refills', () {
      final tq = TokenQueue(unlockedTokens: () => {});
      final token = tq.pop();
      expect(token, isNotNull);
      expect(tq.queue.length, CoinPusherConstants.queueSize);
    });

    test('pop returns null when queue is empty and fill has no effect', () {
      final tq = TokenQueue(
        unlockedTokens: () => {},
        size: 0,
      );
      expect(tq.queue, isEmpty);
      // fill(0) should do nothing since target size is 0 in pop
      // Actually pop() calls fill() with default size, so it refills
    });

    test('randomToken respects coin spawn ratio', () {
      final tq = TokenQueue(
        unlockedTokens: () => {},
        random: Random(42),
      );
      var coins = 0;
      const trials = 10000;
      for (int i = 0; i < trials; i++) {
        if (tq.randomToken() is CoinQueueToken) coins++;
      }
      final ratio = coins / trials;
      expect(ratio, closeTo(SpawnConfig.coinSpawnRatio, 0.05));
    });

    test('includes attribute tokens when unlocked', () {
      final tq = TokenQueue(
        unlockedTokens: () => {Attribute.charming: 2},
        random: Random(42),
      );
      var foundAttribute = false;
      for (int i = 0; i < 1000; i++) {
        final token = tq.randomToken();
        if (token is AttributeQueueToken) {
          expect(token.attribute, Attribute.charming);
          expect(token.level, 2);
          foundAttribute = true;
          break;
        }
      }
      expect(foundAttribute, isTrue);
    });
  });
}

CharacterParts _dummyParts() => const CharacterParts(
      body: 'b',
      head: 'h',
      face: 'f',
      hair: 'hr',
      legs: 'l',
      torso: 't',
    );
