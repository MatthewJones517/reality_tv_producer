# Reality TV Producer

A coin-pusher arcade game built with Flutter and the Flame game engine. Produce your own reality TV show across 5 seasons, manage your cast, unlock attribute chips, and purchase perks to boost your ratings.

## Gameplay

- **Goal**: Get your show renewed for 5 seasons to reach syndication.
- **Mechanics**: Shoot tokens onto the playfield. Coins earn currency; drama and attribute tokens boost your ratings.
- **Cast**: Each season you get a cast of 4 characters with unique attributes. Attribute tokens matching your cast give bonus ratings.
- **Shop**: Between episodes, spend coins to unlock attribute chips and perks.
- **Perks**: Synergy bonuses (e.g., "Double Threat" lets Flirty characters double Charming token ratings).

## Controls

| Key | Action |
|-----|--------|
| Space | Shoot / advance screens |
| A / Arrow Up | Aim launcher down |
| D / Arrow Down | Aim launcher up |

## Running

```bash
flutter run
```

Targets: Linux, macOS, Windows, Web, iOS, Android.

## Project Structure

```
lib/
  main.dart                  # App entry point and overlay registration
  src/
    game.dart                # Main game controller and state machine
    game_config.dart         # Centralized constants, theming, and asset paths
    coin_pusher.dart         # Coin pusher physics and gameplay
    character.dart           # Character, CharacterParts, and Attribute models
    character_generator.dart # Random character generation from sprite assets
    perk.dart                # Perk enum with labels, descriptions, and eligibility
    token_body.dart          # Token physics body and QueueToken types
    pusher_body.dart         # Pusher physics body
    play_screen.dart         # Main gameplay HUD (health, coins, queue, cast)
    shop_screen.dart         # In-game shop UI
    cast_screen.dart         # Cast reveal screen
    title_screen.dart        # Title screen
    show_name_screen.dart    # Show name input overlay
    how_to_play_screen.dart  # How-to-play instructions overlay
    game_over_screen.dart    # Game over overlay
    win_screen.dart          # Victory overlay
    cast_cooldown_overlay.dart # Cast cooldown with reroll option
    character_sprite.dart    # Character sprite rendering
```

## Dependencies

- [Flame](https://flame-engine.org/) -- 2D game engine for Flutter
- [Forge2D](https://pub.dev/packages/forge2d) / [flame_forge2d](https://pub.dev/packages/flame_forge2d) -- 2D physics
- [flutter_soloud](https://pub.dev/packages/flutter_soloud) -- Audio
- [google_fonts](https://pub.dev/packages/google_fonts) -- Font loading

## Testing

```bash
flutter test
```
