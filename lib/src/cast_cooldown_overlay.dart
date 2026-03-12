import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game.dart';

class CastCooldownOverlay extends StatefulWidget {
  final RealityTvGame game;

  const CastCooldownOverlay({super.key, required this.game});

  @override
  State<CastCooldownOverlay> createState() => _CastCooldownOverlayState();
}

class _CastCooldownOverlayState extends State<CastCooldownOverlay> {
  static const _fontFamily = 'VT323';
  static const _spaceDelaySeconds = 5;

  bool _spaceEnabled = false;
  int _remainingSeconds = _spaceDelaySeconds;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
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
            focusNode: FocusNode()..requestFocus(),
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
                      fontFamily: _fontFamily,
                      fontSize: 36,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  if (widget.game.currentSeason >= 2) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: widget.game.coins >= widget.game.castRerollCost
                          ? () {
                              widget.game.rerollContestants();
                              setState(() {});
                            }
                          : null,
                      child: Text(
                        'Reroll contestants (${widget.game.castRerollCost} coins)',
                        style: const TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 24,
                        ),
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
