import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'src/game.dart';
import 'src/show_name_screen.dart';

void main() {
  final game = RealityTvGame();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          'showName': (context, game) =>
              ShowNameScreen(game: game as RealityTvGame),
        },
      ),
    ),
  ));
}
