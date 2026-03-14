import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game.dart';
import 'game_config.dart';

class CastCooldownOverlay extends StatefulWidget {
  final RealityTvGame game;

  const CastCooldownOverlay({super.key, required this.game});

  @override
  State<CastCooldownOverlay> createState() => _CastCooldownOverlayState();
}

class _CastCooldownOverlayState extends State<CastCooldownOverlay> {
  static const _spaceDelaySeconds = 5;

  final _focusNode = FocusNode();
  bool _spaceEnabled = false;
  int _remainingSeconds = _spaceDelaySeconds;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _countdownTimer?.cancel();
          _spaceEnabled = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 48),
          child: KeyboardListener(
            focusNode: _focusNode,
            autofocus: true,
            onKeyEvent: (event) {
              if (!_spaceEnabled) return;
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.space) {
                widget.game.proceedFromCastScreen();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xCC000000),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _spaceEnabled
                        ? 'Press Space to Continue'
                        : 'Continue in $_remainingSeconds seconds',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 36,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  if (widget.game.currentSeason >= GameConfig.rerollSeasonMinimum) ...[
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: widget.game.coins >= widget.game.rerollCost
                          ? () {
                              widget.game.rerollContestants();
                              setState(() {});
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.pink,
                        disabledBackgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 24,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Reroll contestants ('),
                          Image.asset(
                            Assets.coin,
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                          ),
                          Text(' ${widget.game.rerollCost})'),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
