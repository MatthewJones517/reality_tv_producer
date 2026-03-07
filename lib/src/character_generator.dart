import 'dart:math';

import 'package:flutter/services.dart';

class CharacterParts {
  final String body;
  final String face;
  final String hair;
  final String legs;
  final String torso;

  const CharacterParts({
    required this.body,
    required this.face,
    required this.hair,
    required this.legs,
    required this.torso,
  });

  /// Ordered bottom-to-top for rendering layers.
  List<String> get layerPaths => [body, legs, torso, face, hair];
}

class CharacterGenerator {
  static final _random = Random();
  static Map<String, List<String>>? _cache;

  static Future<Map<String, List<String>>> _getAssets() async {
    if (_cache != null) return _cache!;

    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final allAssets = manifest.listAssets();

    _cache = {};
    for (final category in ['body', 'faces', 'hair', 'legs', 'torso']) {
      final prefix = 'assets/characters/$category/';
      _cache![category] = allAssets
          .where((path) => path.startsWith(prefix) && path.endsWith('.png'))
          .map(Uri.decodeFull)
          .toList();
    }
    return _cache!;
  }

  static T _pick<T>(List<T> list) => list[_random.nextInt(list.length)];

  static List<String> _filterGender(List<String> paths, String prefix) {
    final filtered = paths.where((p) {
      final name = p.split('/').last;
      return name.startsWith(prefix);
    }).toList();
    return filtered.isNotEmpty ? filtered : paths;
  }

  static Future<CharacterParts> generate() async {
    final assets = await _getAssets();
    final gender = _random.nextBool() ? 'male_' : 'female_';

    return CharacterParts(
      body: _pick(_filterGender(assets['body']!, gender)),
      face: _pick(_filterGender(assets['faces']!, gender)),
      hair: _pick(assets['hair']!),
      legs: _pick(assets['legs']!),
      torso: _pick(_filterGender(assets['torso']!, gender)),
    );
  }
}
