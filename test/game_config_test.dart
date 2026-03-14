import 'package:flutter_test/flutter_test.dart';
import 'package:reality_tv_producer/src/character.dart';
import 'package:reality_tv_producer/src/game_config.dart';
import 'package:reality_tv_producer/src/perk.dart';

void main() {
  group('ShopConfig.costForLevel', () {
    test('level 0 costs 50', () {
      expect(ShopConfig.costForLevel(0), 50);
    });

    test('level 1 costs 100', () {
      expect(ShopConfig.costForLevel(1), 100);
    });

    test('level 2 costs 150', () {
      expect(ShopConfig.costForLevel(2), 150);
    });

    test('level 3+ costs 200', () {
      expect(ShopConfig.costForLevel(3), 200);
      expect(ShopConfig.costForLevel(10), 200);
    });
  });

  group('Assets.chipPath', () {
    test('capitalizes first letter and adds _Chip.png', () {
      expect(
        Assets.chipPath(Attribute.charming),
        'assets/playfield/Charming_Chip.png',
      );
    });

    test('works for all attributes', () {
      for (final attr in Attribute.values) {
        final path = Assets.chipPath(attr);
        expect(path, startsWith('assets/playfield/'));
        expect(path, endsWith('_Chip.png'));
        expect(path[17], equals(path[17].toUpperCase()));
      }
    });
  });

  group('GameConfig constants', () {
    test('has consistent values', () {
      expect(GameConfig.castSize, greaterThan(0));
      expect(GameConfig.episodesPerSeason, greaterThan(GameConfig.shopTriggerInterval));
      expect(GameConfig.seasonsToWin, greaterThan(0));
    });
  });

  group('Perk.isEligible', () {
    test('perks with no requirements are always eligible', () {
      expect(Perk.isEligible(Perk.marketingBudget, {}), isTrue);
      expect(Perk.isEligible(Perk.memeLord, {}), isTrue);
    });

    test('perks with single requirement need that token unlocked', () {
      expect(Perk.isEligible(Perk.doubleThreat, {}), isFalse);
      expect(
        Perk.isEligible(Perk.doubleThreat, {Attribute.charming: 1}),
        isTrue,
      );
    });

    test('perks with multiple requirements need all tokens unlocked', () {
      expect(Perk.isEligible(Perk.theFeelingIsMutual, {}), isFalse);
      expect(
        Perk.isEligible(
          Perk.theFeelingIsMutual,
          {Attribute.nosy: 1},
        ),
        isFalse,
      );
      expect(
        Perk.isEligible(
          Perk.theFeelingIsMutual,
          {Attribute.nosy: 1, Attribute.paranoid: 1},
        ),
        isTrue,
      );
    });

    test('level 0 tokens do not count as unlocked', () {
      expect(
        Perk.isEligible(Perk.doubleThreat, {Attribute.charming: 0}),
        isFalse,
      );
    });
  });

  group('perkDoublerMappings', () {
    test('all doubler perks have entries in the mapping', () {
      final doublerPerks = Perk.values.where(
        (p) => p != Perk.marketingBudget && p != Perk.memeLord,
      );
      for (final perk in doublerPerks) {
        expect(
          perkDoublerMappings.containsKey(perk),
          isTrue,
          reason: '${perk.name} should have a doubler mapping',
        );
      }
    });

    test('each mapping has non-empty list', () {
      for (final entry in perkDoublerMappings.entries) {
        expect(entry.value, isNotEmpty, reason: '${entry.key.name} mapping should not be empty');
      }
    });

    test('theFeelingIsMutual is bidirectional', () {
      final mappings = perkDoublerMappings[Perk.theFeelingIsMutual]!;
      expect(mappings.length, 2);
      expect(mappings[0].trigger, Attribute.paranoid);
      expect(mappings[0].bonus, Attribute.nosy);
      expect(mappings[1].trigger, Attribute.nosy);
      expect(mappings[1].bonus, Attribute.paranoid);
    });
  });

  group('Attribute enum', () {
    test('every attribute has a label', () {
      for (final attr in Attribute.values) {
        expect(attr.label, isNotEmpty);
      }
    });
  });

  group('Perk enum', () {
    test('every perk has a label and description', () {
      for (final perk in Perk.values) {
        expect(perk.label, isNotEmpty);
        expect(perk.description, isNotEmpty);
      }
    });
  });
}
