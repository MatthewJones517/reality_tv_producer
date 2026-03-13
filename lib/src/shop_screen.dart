import 'dart:math';

import 'package:flutter/material.dart';

import 'character.dart';
import 'game.dart';
import 'perk.dart';

class ShopScreen extends StatefulWidget {
  final RealityTvGame game;

  const ShopScreen({super.key, required this.game});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  static const _pink = Color(0xFFFF1493);
  static const _fontFamily = 'VT323';
  static int _costForLevel(int currentLevel) {
    return switch (currentLevel) {
      0 => 100,
      1 => 150,
      2 => 200,
      _ => 200,
    };
  }

  late List<Attribute> _options;
  late List<Perk> _perkOptions;
  final _random = Random();
  final Set<Attribute> _purchasedThisSession = {};
  static const _perkCost = 200;
  final _unlockedScrollController = ScrollController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _pickOptions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _unlockedScrollController.dispose();
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
      if (level >= 3) continue;
      eligible.add(attr);
    }
    eligible.shuffle(_random);
    final eligiblePerks =
        Perk.values.where((p) => !widget.game.ownedPerks.contains(p)).toList()
          ..shuffle(_random);
    setState(() {
      _options = eligible.take(3).toList();
      _perkOptions = eligiblePerks.take(3).toList();
    });
  }

  void _purchasePerk(Perk perk) {
    if (widget.game.coins < _perkCost) return;
    if (widget.game.ownedPerks.contains(perk)) return;
    setState(() {
      widget.game.coins -= _perkCost;
      widget.game.ownedPerks.add(perk);
      _pickOptions();
    });
  }

  void _purchase(Attribute attr) {
    final current = widget.game.unlockedTokens[attr] ?? 0;
    if (current >= 3) return;
    final cost = _costForLevel(current);
    if (widget.game.coins < cost) return;

    setState(() {
      widget.game.coins -= cost;
      final isFirstUnlock = current == 0;
      widget.game.unlockedTokens[attr] = current + 1;
      _purchasedThisSession.add(attr);
      if (isFirstUnlock) {
        widget.game.convertDramaToAttribute(attr);
      }
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
                  border: Border.all(color: _pink, width: 3),
                ),
                child: ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thumbColor: WidgetStateProperty.all(_pink),
                  ),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: SizedBox(
                        width: 1200,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Coins: ${widget.game.coins}',
                                        style: const TextStyle(
                                          fontFamily: _fontFamily,
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
                                                fontFamily: 'CinzelDecorative',
                                                fontSize: 48,
                                                fontWeight: FontWeight.bold,
                                                color: _pink,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 16,
                                        ),
                                        child: ElevatedButton(
                                          onPressed:
                                              widget.game.coins >=
                                                  widget.game.rerollCost
                                              ? _rerollShop
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _pink,
                                            disabledBackgroundColor:
                                                Colors.grey,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                            textStyle: const TextStyle(
                                              fontFamily: _fontFamily,
                                              fontSize: 24,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text('Reroll ('),
                                              Image.asset(
                                                'assets/playfield/coin.png',
                                                width: 24,
                                                height: 24,
                                                fit: BoxFit.contain,
                                              ),
                                              Text(
                                                ' ${widget.game.rerollCost})',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
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
                                            widget.game.unlockedTokens[attr] ??
                                            0;
                                        final canUnlock = level == 0;
                                        final canLevelUp =
                                            level > 0 && level < 3;
                                        final cost = _costForLevel(level);
                                        final notPurchasedThisSession =
                                            !_purchasedThisSession.contains(
                                              attr,
                                            );
                                        final canBuy =
                                            notPurchasedThisSession &&
                                            (canUnlock || canLevelUp) &&
                                            widget.game.coins >= cost;

                                        final grayedOut = _purchasedThisSession
                                            .contains(attr);
                                        return _ShopOption(
                                          attribute: attr,
                                          level:
                                              widget
                                                  .game
                                                  .unlockedTokens[attr] ??
                                              0,
                                          cost: cost,
                                          canBuy: canBuy,
                                          isLevelUp: level > 0,
                                          grayedOut: grayedOut,
                                          onPurchase: () => _purchase(attr),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Unlocked Chips',
                                    style: TextStyle(
                                      fontFamily: 'CinzelDecorative',
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: _pink,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 200,
                                    child: ScrollbarTheme(
                                      data: ScrollbarThemeData(
                                        thumbColor: WidgetStateProperty.all(
                                          _pink,
                                        ),
                                      ),
                                      child: Scrollbar(
                                        controller: _unlockedScrollController,
                                        thumbVisibility: true,
                                        child: ListView(
                                          controller: _unlockedScrollController,
                                          padding: const EdgeInsets.only(
                                            left: 24,
                                            right: 16,
                                          ),
                                          children: [
                                            if (widget
                                                .game
                                                .unlockedTokens
                                                .isEmpty)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                    ),
                                                child: Text(
                                                  'Attribute chips give you an additional '
                                                  'ratings boost for each character with the '
                                                  'matching attribute',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily: _fontFamily,
                                                    fontSize: 22,
                                                    color: Colors.white
                                                        .withValues(alpha: 0.7),
                                                  ),
                                                ),
                                              )
                                            else
                                              ...widget.game.unlockedTokens.entries.map(
                                                (e) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 12,
                                                      ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        width: 48,
                                                        height: 48,
                                                        child: Image.asset(
                                                          'assets/playfield/${e.key.name[0].toUpperCase()}${e.key.name.substring(1)}_Chip.png',
                                                          width: 48,
                                                          height: 48,
                                                          fit: BoxFit.contain,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) =>
                                                                  const SizedBox(
                                                                    width: 48,
                                                                    height: 48,
                                                                  ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        '${e.key.label} Lv.${e.value}',
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              _fontFamily,
                                                          fontSize: 28,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 400,
                              color: _pink.withValues(alpha: 0.5),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Perks',
                                      style: TextStyle(
                                        fontFamily: 'CinzelDecorative',
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: _pink,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    if (_perkOptions.isEmpty)
                                      Text(
                                        'No perks available right now.',
                                        style: const TextStyle(
                                          fontFamily: _fontFamily,
                                          fontSize: 22,
                                          color: Colors.white,
                                        ),
                                      )
                                    else
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: _perkOptions.map((perk) {
                                          final canBuy =
                                              widget.game.coins >= _perkCost;
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 16,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  perk.label,
                                                  style: const TextStyle(
                                                    fontFamily: _fontFamily,
                                                    fontSize: 26,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF87CEEB),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  perk.description,
                                                  style: const TextStyle(
                                                    fontFamily: _fontFamily,
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                ElevatedButton(
                                                  onPressed: canBuy
                                                      ? () =>
                                                            _purchasePerk(perk)
                                                      : null,
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: _pink,
                                                    disabledBackgroundColor:
                                                        Colors.grey,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 24,
                                                          vertical: 10,
                                                        ),
                                                    textStyle: const TextStyle(
                                                      fontFamily: _fontFamily,
                                                      fontSize: 22,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Text('Buy ('),
                                                      Image.asset(
                                                        'assets/playfield/coin.png',
                                                        width: 20,
                                                        height: 20,
                                                        fit: BoxFit.contain,
                                                      ),
                                                      Text(' $_perkCost)'),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
                  backgroundColor: _pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontFamily: _fontFamily,
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

  static const _fontFamily = 'VT323';
  static const _pink = Color(0xFFFF1493);

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
            color: canBuy ? _pink : Colors.grey.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/playfield/${attribute.name[0].toUpperCase()}${attribute.name.substring(1)}_Chip.png',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox(width: 80, height: 80),
            ),
            const SizedBox(height: 8),
            Text(
              attribute.label,
              style: const TextStyle(
                fontFamily: _fontFamily,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            if (level > 0)
              Text(
                'Level $level',
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 20,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            const SizedBox(height: 4),
            ElevatedButton(
              onPressed: canBuy ? onPurchase : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _pink,
                disabledBackgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: Text(
                isLevelUp ? 'Level up ($cost)' : 'Unlock ($cost)',
                style: const TextStyle(fontFamily: _fontFamily, fontSize: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
