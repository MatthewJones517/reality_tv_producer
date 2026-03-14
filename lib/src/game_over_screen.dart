import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game.dart';
import 'game_config.dart';

class GameOverScreen extends StatefulWidget {
  final RealityTvGame game;

  const GameOverScreen({super.key, required this.game});

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
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

  static String _ordinalWord(int n) {
    return switch (n) {
      1 => 'first',
      2 => 'second',
      3 => 'third',
      4 => 'fourth',
      5 => 'fifth',
      _ => '$n',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xCC000000),
      child: KeyboardListener(
        focusNode: _focusNode,
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
              border: Border.all(color: AppTheme.pink, width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "You've Been Cancelled!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.headingFontFamily,
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.pink,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${widget.game.showName ?? "Your show"} was canceled during its '
                  '${_ordinalWord(widget.game.currentSeason)} season.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 32,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  _spaceEnabled
                      ? 'Press Space to Continue'
                      : 'Continue in $_remainingSeconds seconds',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
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
