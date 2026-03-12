import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'src/cast_cooldown_overlay.dart';
import 'src/game.dart';
import 'src/game_over_screen.dart';
import 'src/how_to_play_screen.dart';
import 'src/show_name_screen.dart';
import 'src/shop_screen.dart';
import 'src/win_screen.dart';

void main() {
  final gameFocusNode = FocusNode();
  final game = RealityTvGame(gameFocusNode: gameFocusNode);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: GameWidget(
          game: game,
          focusNode: gameFocusNode,
          overlayBuilderMap: {
            'showName': (context, game) =>
                ShowNameScreen(game: game as RealityTvGame),
            'howToPlay': (context, game) =>
                HowToPlayScreen(game: game as RealityTvGame),
            'castCooldown': (context, game) =>
                CastCooldownOverlay(game: game as RealityTvGame),
            'gameOver': (context, game) =>
                GameOverScreen(game: game as RealityTvGame),
            'shop': (context, game) =>
                ShopScreen(game: game as RealityTvGame),
            'win': (context, game) =>
                WinScreen(game: game as RealityTvGame),
          },
      ),
    ),
  ));
}
