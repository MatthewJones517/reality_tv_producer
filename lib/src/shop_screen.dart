import 'dart:math';

import 'package:flutter/material.dart';

import 'character.dart';
import 'game.dart';
import 'game_config.dart';
import 'perk.dart';

class ShopScreen extends StatefulWidget {
  final RealityTvGame game;

  const ShopScreen({super.key, required this.game});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late List<Attribute> _options;
  late List<Perk> _perkOptions;
  final _random = Random();
  final Set<Attribute> _purchasedThisSession = {};
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _pickOptions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _rerollShop() {
    if (!widget.game.performReroll()) return;
    setState(() => _pickOptions());
  }

  void _pickOptions() {
    final eligible = <Attribute>[];
    for (final attr in Attribute.values) {
      final level = widget.game.unlockedTokens[attr] ?? 0;
      if (level >= GameConfig.maxAttributeLevel) continue;
      eligible.add(attr);
    }

    final isFirstShop = widget.game.currentEpisode == GameConfig.shopTriggerInterval;
    final castAttributes = widget.game.currentCast
        .expand((c) => c.attributes)
        .toSet();
    final eligibleMatchingCast =
        eligible.where((a) => castAttributes.contains(a)).toList();

    List<Attribute> options;
    if (isFirstShop &&
        eligibleMatchingCast.isNotEmpty &&
        eligible.length >= ShopConfig.shopOptionsCount) {
      final match = eligibleMatchingCast[_random.nextInt(eligibleMatchingCast.length)];
      final rest = eligible.where((a) => a != match).toList()..shuffle(_random);
      options = [match, ...rest.take(2)];
    } else {
      eligible.shuffle(_random);
      options = eligible.take(ShopConfig.shopOptionsCount).toList();
    }

    final unlocked = widget.game.unlockedTokens;
    final eligiblePerks =
        Perk.values
            .where(
              (p) =>
                  !widget.game.ownedPerks.contains(p) &&
                  Perk.isEligible(p, unlocked),
            )
            .toList()
          ..shuffle(_random);
    setState(() {
      _options = options;
      _perkOptions = eligiblePerks.take(ShopConfig.shopOptionsCount).toList();
    });
  }

  void _purchasePerk(Perk perk) {
    if (!widget.game.purchasePerk(perk)) return;
    setState(() => _pickOptions());
  }

  void _purchase(Attribute attr) {
    if (!widget.game.purchaseAttribute(attr)) return;
    setState(() {
      _purchasedThisSession.add(attr);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xCC000000),
      child: Center(
        child: Transform.translate(
          offset: const Offset(0, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 1200,
                constraints: const BoxConstraints(maxHeight: 500),
                margin: const EdgeInsets.symmetric(vertical: 24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xEE111111),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.pink, width: 3),
                ),
                child: ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thumbColor: WidgetStateProperty.all(AppTheme.pink),
                  ),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _ShopHeader(
                                      coins: widget.game.coins,
                                      rerollCost: widget.game.rerollCost,
                                      canReroll:
                                          widget.game.coins >=
                                          widget.game.rerollCost,
                                      onReroll: _rerollShop,
                                    ),
                                    const SizedBox(height: 24),
                                    Transform.translate(
                                      offset: const Offset(-24, 0),
                                      child: Wrap(
                                        spacing: 24,
                                        runSpacing: 24,
                                        alignment: WrapAlignment.center,
                                        children: _options.map((attr) {
                                          final level =
                                              widget
                                                  .game
                                                  .unlockedTokens[attr] ??
                                              0;
                                          final cost = ShopConfig.costForLevel(level);
                                          final alreadyPurchased =
                                              _purchasedThisSession.contains(
                                                attr,
                                              );
                                          final canBuy =
                                              !alreadyPurchased &&
                                              level < GameConfig.maxAttributeLevel &&
                                              widget.game.coins >= cost;
                                          return _ShopOption(
                                            attribute: attr,
                                            level: level,
                                            cost: cost,
                                            canBuy: canBuy,
                                            isLevelUp: level > 0,
                                            grayedOut: alreadyPurchased,
                                            onPurchase: () => _purchase(attr),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: _UnlockedChipsList(
                                        unlockedTokens:
                                            widget.game.unlockedTokens,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: _UnlockedPerksList(
                                        ownedPerks: widget.game.ownedPerks,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 2,
                                color: AppTheme.pink.withValues(alpha: 0.5),
                              ),
                              _PerksPanel(
                                perkOptions: _perkOptions,
                                coins: widget.game.coins,
                                perkCost: ShopConfig.perkCost,
                                onPurchasePerk: _purchasePerk,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              ElevatedButton(
                onPressed: () => widget.game.finishShop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 36,
                  ),
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared ──────────────────────────────────────────────────────────────────

class _CoinCostButton extends StatelessWidget {
  final String label;
  final int cost;
  final VoidCallback? onPressed;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const _CoinCostButton({
    required this.label,
    required this.cost,
    required this.onPressed,
    this.fontSize = 24,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.pink,
        disabledBackgroundColor: Colors.grey,
        foregroundColor: Colors.white,
        padding: padding,
        textStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: fontSize),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label ('),
          Image.asset(
            Assets.coin,
            width: fontSize,
            height: fontSize,
            fit: BoxFit.contain,
          ),
          Text(' $cost)'),
        ],
      ),
    );
  }
}

// ─── Shop Header ─────────────────────────────────────────────────────────────

class _ShopHeader extends StatelessWidget {
  final int coins;
  final int rerollCost;
  final bool canReroll;
  final VoidCallback onReroll;

  const _ShopHeader({
    required this.coins,
    required this.rerollCost,
    required this.canReroll,
    required this.onReroll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Coins: $coins',
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 32,
            color: Colors.white,
          ),
        ),
        Expanded(
          child: Center(
            child: Transform.translate(
              offset: const Offset(8, 0),
              child: const Text(
                'Shop',
                style: TextStyle(
                  fontFamily: AppTheme.headingFontFamily,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.pink,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _CoinCostButton(
            label: 'Reroll',
            cost: rerollCost,
            onPressed: canReroll ? onReroll : null,
          ),
        ),
      ],
    );
  }
}

// ─── Unlocked Chips ───────────────────────────────────────────────────────────

class _UnlockedChipsList extends StatelessWidget {
  final Map<Attribute, int> unlockedTokens;

  const _UnlockedChipsList({required this.unlockedTokens});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Unlocked Chips',
          style: TextStyle(
            fontFamily: AppTheme.headingFontFamily,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.pink,
          ),
        ),
        const SizedBox(height: 16),
        if (unlockedTokens.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24),
            child: Text(
              'Attribute chips give you an additional '
              'ratings boost for each character with the '
              'matching attribute',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 22,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          )
        else
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: unlockedTokens.entries
                .map(
                  (e) => Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        Assets.chipPath(e.key),
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) =>
                            const SizedBox(width: 48, height: 48),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${e.key.label} Lv.${e.value}',
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 28,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _UnlockedPerksList extends StatelessWidget {
  final Set<Perk> ownedPerks;

  const _UnlockedPerksList({required this.ownedPerks});

  @override
  Widget build(BuildContext context) {
    if (ownedPerks.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Unlocked Perks',
          style: TextStyle(
            fontFamily: AppTheme.headingFontFamily,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.pink,
          ),
        ),
        const SizedBox(height: 16),
        ...ownedPerks.map(
          (perk) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  perk.label,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.perkLabelColor,
                  ),
                ),
                Text(
                  perk.description,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Perks ────────────────────────────────────────────────────────────────────

class _PerkCard extends StatelessWidget {
  final Perk perk;
  final bool canBuy;
  final VoidCallback onPurchase;
  final int cost;

  const _PerkCard({
    required this.perk,
    required this.canBuy,
    required this.onPurchase,
    required this.cost,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            perk.label,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppTheme.perkLabelColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            perk.description,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          _CoinCostButton(
            label: 'Buy',
            cost: cost,
            onPressed: canBuy ? onPurchase : null,
            fontSize: 22,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          ),
        ],
      ),
    );
  }
}

class _PerksPanel extends StatelessWidget {
  final List<Perk> perkOptions;
  final int coins;
  final int perkCost;
  final void Function(Perk) onPurchasePerk;

  const _PerksPanel({
    required this.perkOptions,
    required this.coins,
    required this.perkCost,
    required this.onPurchasePerk,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Perks',
              style: TextStyle(
                fontFamily: AppTheme.headingFontFamily,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.pink,
              ),
            ),
            const SizedBox(height: 16),
            if (perkOptions.isEmpty)
              const Text(
                'No perks available right now.',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 22,
                  color: Colors.white,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: perkOptions
                    .map(
                      (perk) => _PerkCard(
                        perk: perk,
                        canBuy: coins >= perkCost,
                        onPurchase: () => onPurchasePerk(perk),
                        cost: perkCost,
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Shop Option ──────────────────────────────────────────────────────────────

class _ShopOption extends StatelessWidget {
  final Attribute attribute;
  final int level;
  final int cost;
  final bool canBuy;
  final bool isLevelUp;
  final bool grayedOut;
  final VoidCallback onPurchase;

  const _ShopOption({
    required this.attribute,
    required this.level,
    required this.cost,
    required this.canBuy,
    required this.isLevelUp,
    this.grayedOut = false,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: grayedOut ? 0.5 : 1.0,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: canBuy ? AppTheme.pink : Colors.grey.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              Assets.chipPath(attribute),
              width: 80,
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox(width: 80, height: 80),
            ),
            const SizedBox(height: 8),
            Text(
              attribute.label,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            if (level > 0)
              Text(
                'Level $level',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 20,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            const SizedBox(height: 4),
            ElevatedButton(
              onPressed: canBuy ? onPurchase : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.pink,
                disabledBackgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: Text(
                isLevelUp ? 'Level up ($cost)' : 'Unlock ($cost)',
                style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
