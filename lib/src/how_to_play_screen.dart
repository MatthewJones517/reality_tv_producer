import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game.dart';
import 'game_config.dart';

class HowToPlayScreen extends StatefulWidget {
  final RealityTvGame game;

  const HowToPlayScreen({super.key, required this.game});

  @override
  State<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends State<HowToPlayScreen> {

  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xCC000000),
      child: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.space) {
            widget.game.finishHowToPlay();
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
                border: Border.all(color: AppTheme.pink, width: 3),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'How To Play',
                    style: TextStyle(
                      fontFamily: AppTheme.headingFontFamily,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.pink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Get your show renewed for 5 seasons and reach syndication!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 30,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoLine(
                    Icons.gamepad_rounded,
                    Colors.lightBlueAccent,
                    '- Space to shoot.\n- A / Up and D / Down to aim.',
                  ),
                  const SizedBox(height: 24),
                  _buildTokenRow(
                    Assets.dramaChip,
                    64,
                    'Push drama tokens to increase ratings.',
                  ),
                  const SizedBox(height: 24),
                  _buildTokenRow(
                    Assets.coin,
                    38,
                    'Push coin tokens to buy stuff.',
                  ),
                  const SizedBox(height: 24),
                  _buildInfoLine(
                    Icons.warning_amber_rounded,
                    Colors.orangeAccent,
                    "If your ratings slip, you'll get cancelled!",
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Press Space to Continue',
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
              fontFamily: AppTheme.fontFamily,
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
              fontFamily: AppTheme.fontFamily,
              fontSize: 32,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
