import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'src/cast_cooldown_overlay.dart';
import 'src/game.dart';
import 'src/game_config.dart';
import 'src/game_over_screen.dart';
import 'src/how_to_play_screen.dart';
import 'src/show_name_screen.dart';
import 'src/shop_screen.dart';
import 'src/win_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final gameFocusNode = FocusNode();
  final game = RealityTvGame(gameFocusNode: gameFocusNode);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: GameWidget(
          game: game,
          focusNode: gameFocusNode,
          loadingBuilder: (context) => Container(
            color: Colors.black,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 48,
                      color: AppTheme.pink,
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      color: AppTheme.pink,
                      backgroundColor: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
          ),
          overlayBuilderMap: {
            Overlays.showName: (context, game) =>
                ShowNameScreen(game: game as RealityTvGame),
            Overlays.howToPlay: (context, game) =>
                HowToPlayScreen(game: game as RealityTvGame),
            Overlays.castCooldown: (context, game) =>
                CastCooldownOverlay(game: game as RealityTvGame),
            Overlays.gameOver: (context, game) =>
                GameOverScreen(game: game as RealityTvGame),
            Overlays.shop: (context, game) =>
                ShopScreen(game: game as RealityTvGame),
            Overlays.win: (context, game) =>
                WinScreen(game: game as RealityTvGame),
          },
      ),
    ),
  ));
}
