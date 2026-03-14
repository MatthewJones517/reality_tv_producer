import 'package:flutter/material.dart';

import 'character.dart';
import 'perk.dart';

// ─── Overlay Names ───────────────────────────────────────────────────────────

abstract final class Overlays {
  static const showName = 'showName';
  static const howToPlay = 'howToPlay';
  static const castCooldown = 'castCooldown';
  static const gameOver = 'gameOver';
  static const shop = 'shop';
  static const win = 'win';
}

// ─── Game Flow ───────────────────────────────────────────────────────────────

abstract final class GameConfig {
  static const castSize = 4;
  static const episodeDurationSeconds = 10.0;
  static const shopTriggerInterval = 3;
  static const episodesPerSeason = 12;
  static const seasonsToWin = 5;
  static const rerollBaseCost = 5;
  static const rerollSeasonMinimum = 2;
  static const maxAttributeLevel = 3;
}

// ─── Shop ────────────────────────────────────────────────────────────────────

abstract final class ShopConfig {
  static const perkCost = 175;
  static const shopOptionsCount = 3;

  static int costForLevel(int currentLevel) {
    return switch (currentLevel) {
      0 => 50,
      1 => 100,
      2 => 150,
      _ => 200,
    };
  }
}

// ─── Health & Ratings ────────────────────────────────────────────────────────

abstract final class HealthConfig {
  static const maxHealth = 100.0;
  static const initialHealth = 100.0;
  static const baseDrainRate = 3.0;
  static const baseHealthGain = 5.0;
  static const marketingBudgetCoinBonus = 0.5;

  static const memeLordChance = 0.05;
  static const memeLordMultiplier = 10;
  static const memeLordFlashDuration = 3.0;

  /// Season 1-4 use a 1.2x exponential, after that it's
  /// 1.2^3 * 1.15^(season-4).
  static const drainEarlyBase = 1.2;
  static const drainEarlySeasons = 4;
  static const drainLateBase = 1.15;
}

// ─── Token Spawning ──────────────────────────────────────────────────────────

abstract final class SpawnConfig {
  static const coinSpawnRatio = 0.90;
  static const dramaConvertFraction = 3;
}

// ─── Theming ─────────────────────────────────────────────────────────────────

abstract final class AppTheme {
  static const pink = Color(0xFFFF1493);
  static const perkLabelColor = Color(0xFF87CEEB);
  static const fontFamily = 'VT323';
  static const headingFontFamily = 'CinzelDecorative';
}

// ─── Asset Paths ─────────────────────────────────────────────────────────────

abstract final class Assets {
  static String chipPath(Attribute attr) {
    final name = attr.name;
    return 'assets/playfield/${name[0].toUpperCase()}${name.substring(1)}_Chip.png';
  }

  static const coin = 'assets/playfield/coin.png';
  static const dramaChip = 'assets/playfield/Drama_Chip.png';
  static const launcher = 'assets/playfield/launcher.png';
  static const edge = 'assets/playfield/edge.png';
  static const smoke = 'assets/playfield/smoke.png';
  static const tvNoAntenna = 'assets/playfield/tv_no_antenna.png';
  static const pusher = 'assets/playfield/pusher.png';
  static const titleBg = 'assets/title_screen/bg.png';
}

// ─── Perk Doubler Mappings ───────────────────────────────────────────────────
/// Each doubler perk maps (trigger attribute) -> (bonus attribute).
/// When a token with [trigger] is collected, characters with [bonus]
/// count as additional matches.

typedef DoublerMapping = ({Attribute trigger, Attribute bonus});

const perkDoublerMappings = <Perk, List<DoublerMapping>>{
  Perk.doubleThreat: [(trigger: Attribute.charming, bonus: Attribute.flirty)],
  Perk.loveTriangle: [(trigger: Attribute.flirty, bonus: Attribute.jealous)],
  Perk.tooEasy: [(trigger: Attribute.oblivious, bonus: Attribute.scheming)],
  Perk.didYouHearAbout: [(trigger: Attribute.nosy, bonus: Attribute.chatty)],
  Perk.theMole: [(trigger: Attribute.scheming, bonus: Attribute.loyal)],
  Perk.theyreDefinitelyOntoMe: [
    (trigger: Attribute.oblivious, bonus: Attribute.paranoid),
  ],
  Perk.theFeelingIsMutual: [
    (trigger: Attribute.paranoid, bonus: Attribute.nosy),
    (trigger: Attribute.nosy, bonus: Attribute.paranoid),
  ],
  Perk.crickets: [(trigger: Attribute.stoic, bonus: Attribute.chatty)],
};
