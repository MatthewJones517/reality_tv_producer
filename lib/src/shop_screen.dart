import 'dart:math';

import 'package:flutter/material.dart';

import 'character.dart';
import 'game.dart';

class ShopScreen extends StatefulWidget {
  final RealityTvGame game;

  const ShopScreen({super.key, required this.game});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  static const _pink = Color(0xFFFF1493);
  static const _fontFamily = 'VT323';
  static const _unlockCost = 75;

  late List<Attribute> _options;
  final _random = Random();
  final Set<Attribute> _purchasedThisSession = {};

  @override
  void initState() {
    super.initState();
    _pickOptions();
  }

  void _pickOptions() {
    final eligible = <Attribute>[];
    for (final attr in Attribute.values) {
      final level = widget.game.unlockedTokens[attr] ?? 0;
      if (level >= 3) continue;
      if (level > 0) {
        eligible.add(attr);
      } else if (widget.game.unlockedTokens.length < 3) {
        eligible.add(attr);
      }
    }
    eligible.shuffle(_random);
    setState(() {
      _options = eligible.take(3).toList();
    });
  }

  void _purchase(Attribute attr) {
    if (widget.game.coins < _unlockCost) return;
    final current = widget.game.unlockedTokens[attr] ?? 0;
    if (current >= 3) return;
    if (current == 0 && widget.game.unlockedTokens.length >= 3) return;

    setState(() {
      widget.game.coins -= _unlockCost;
      widget.game.unlockedTokens[attr] = current + 1;
      _purchasedThisSession.add(attr);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xCC000000),
      child: Center(
        child: Container(
          width: 1200,
          margin: const EdgeInsets.symmetric(vertical: 24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xEE111111),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _pink, width: 3),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Shop',
                      style: const TextStyle(
                        fontFamily: 'CinzelDecorative',
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: _pink,
                      ),
                    ),
                    Text(
                      'Coins: ${widget.game.coins}',
                      style: const TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      alignment: WrapAlignment.center,
                      children: _options.map((attr) {
                        final level =
                            widget.game.unlockedTokens[attr] ?? 0;
                        final canUnlock = level == 0 &&
                            widget.game.unlockedTokens.length < 3;
                        final canLevelUp = level > 0 && level < 3;
                        final notPurchasedThisSession =
                            !_purchasedThisSession.contains(attr);
                        final canBuy =
                            notPurchasedThisSession &&
                            (canUnlock || canLevelUp) &&
                            widget.game.coins >= _unlockCost;

                        final grayedOut = _purchasedThisSession.contains(attr);
                        return _ShopOption(
                          attribute: attr,
                          level: widget.game.unlockedTokens[attr] ?? 0,
                          cost: _unlockCost,
                          canBuy: canBuy,
                          isLevelUp: level > 0,
                          grayedOut: grayedOut,
                          onPurchase: () => _purchase(attr),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => widget.game.finishShop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 48, vertical: 16),
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
              Container(
                width: 2,
                height: 400,
                color: _pink.withValues(alpha: 0.5),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Unlocked Chips (${widget.game.unlockedTokens.length}/3)',
                      style: const TextStyle(
                        fontFamily: 'CinzelDecorative',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _pink,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (widget.game.unlockedTokens.isEmpty)
                      Text(
                        'None yet',
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 28,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      )
                    else
                      ...widget.game.unlockedTokens.entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/playfield/${e.key.name[0].toUpperCase()}${e.key.name.substring(1)}_Chip.png',
                                width: 48,
                                height: 48,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const SizedBox(
                                  width: 48,
                                  height: 48,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${e.key.label} Lv.${e.value}',
                                style: const TextStyle(
                                  fontFamily: _fontFamily,
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
            errorBuilder: (context, error, stackTrace) => const SizedBox(
              width: 80,
              height: 80,
            ),
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
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: canBuy ? onPurchase : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _pink,
              disabledBackgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
