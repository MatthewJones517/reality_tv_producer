import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game.dart';

class HowToPlayScreen extends StatelessWidget {
  final RealityTvGame game;

  const HowToPlayScreen({super.key, required this.game});

  static const _pink = Color(0xFFFF1493);
  static const _fontFamily = 'VT323';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xCC000000),
      child: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.space) {
            game.finishHowToPlay();
          }
        },
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 900,
              margin: const EdgeInsets.symmetric(vertical: 24),
              padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 36),
              decoration: BoxDecoration(
                color: const Color(0xEE111111),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _pink, width: 3),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'How To Play',
                    style: TextStyle(
                      fontFamily: 'CinzelDecorative',
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _pink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Get your show renewed for 5 seasons and reach syndication!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 30,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTokenRow(
                    'assets/tokens/Drama_Chip.png',
                    64,
                    'Push drama tokens to increase ratings.',
                  ),
                  const SizedBox(height: 16),
                  _buildTokenRow(
                    'assets/tokens/coin.png',
                    38,
                    'Push coin tokens to buy perks\nand additional tokens.',
                  ),
                  const SizedBox(height: 24),
                  _buildInfoLine(
                    Icons.warning_amber_rounded,
                    Colors.orangeAccent,
                    "Don't let your ratings slip!\nIf they drop too low you risk cancellation!",
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Press Space to Continue',
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
      ),
    );
  }

  Widget _buildTokenRow(String assetPath, double imageSize, String text) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Center(
            child: Image.asset(
              assetPath,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 32,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoLine(IconData icon, Color iconColor, String text) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Center(child: Icon(icon, color: iconColor, size: 48)),
        ),
        const SizedBox(width: 20),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 32,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
