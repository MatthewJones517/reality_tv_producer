import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game.dart';

class WinScreen extends StatefulWidget {
  final RealityTvGame game;

  const WinScreen({super.key, required this.game});

  @override
  State<WinScreen> createState() => _WinScreenState();
}

class _WinScreenState extends State<WinScreen> {
  static const _pink = Color(0xFFFF1493);
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
      color: const Color(0xCC000000),
      child: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        autofocus: true,
        onKeyEvent: (event) {
          if (!_spaceEnabled) return;
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.space) {
            widget.game.resetToTitle();
          }
        },
        child: Center(
          child: Container(
            width: 900,
            margin: const EdgeInsets.symmetric(vertical: 24),
            padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 48),
            decoration: BoxDecoration(
              color: const Color(0xEE111111),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _pink, width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Congratulations!\n',
                        style: TextStyle(
                          fontFamily: 'CinzelDecorative',
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: _pink,
                        ),
                      ),
                      TextSpan(
                        text:
                            '${widget.game.showName ?? "Your show"} has reached syndication! You win! Can you do it again?',
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 42,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  _spaceEnabled
                      ? 'Press Space to Continue'
                      : 'Continue in $_remainingSeconds seconds',
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 36,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
