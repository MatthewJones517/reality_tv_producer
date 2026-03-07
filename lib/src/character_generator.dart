import 'dart:math';

import 'package:flutter/services.dart';

class CharacterParts {
  final String body;
  final String head;
  final String face;
  final String hair;
  final String legs;
  final String torso;

  const CharacterParts({
    required this.body,
    required this.head,
    required this.face,
    required this.hair,
    required this.legs,
    required this.torso,
  });

  /// Ordered bottom-to-top for rendering layers.
  List<String> get layerPaths => [body, head, legs, torso, face, hair];
}

class CharacterGenerator {
  static final _random = Random();
  static Map<String, List<String>>? _cache;

  static Future<Map<String, List<String>>> _getAssets() async {
    if (_cache != null) return _cache!;

    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final allAssets = manifest.listAssets();

    _cache = {};
    for (final category in [
      'body',
      'faces',
      'heads',
      'hair',
      'legs',
      'torso',
    ]) {
      final prefix = 'assets/characters/$category/';
      _cache![category] = allAssets
          .where((path) => path.startsWith(prefix) && path.endsWith('.png'))
          .map(Uri.decodeFull)
          .toList();
    }
    return _cache!;
  }

  static T _pick<T>(List<T> list) => list[_random.nextInt(list.length)];

  static String _filename(String path) =>
      path.split('/').last.replaceAll('.png', '');

  static List<String> _filterGender(List<String> paths, String gender) {
    final filtered =
        paths.where((p) => _filename(p).startsWith(gender)).toList();
    return filtered.isNotEmpty ? filtered : paths;
  }

  /// Extracts the skin-tone color from a head path.
  /// Head format: `{gender}_head_{color}.png`
  static String _headColor(String headPath, String gender) {
    final name = _filename(headPath);
    // Strip "{gender}_head_" prefix (gender already includes trailing '_').
    return name.substring(gender.length + 5); // 5 = "head_".length
  }

  /// Filters face paths to those whose color suffix matches [color].
  /// Face format: `{gender}_{expression}_{color}.png`
  static List<String> _facesWithColor(
    List<String> faces,
    String gender,
    String color,
  ) {
    return faces.where((p) {
      final withoutGender = _filename(p).substring(gender.length);
      final faceColor =
          withoutGender.substring(withoutGender.indexOf('_') + 1);
      return faceColor == color;
    }).toList();
  }

  /// Filters body paths to those whose color suffix matches [color].
  /// Body format: `{gender}_{color}.png`
  static List<String> _bodiesWithColor(
    List<String> bodies,
    String gender,
    String color,
  ) {
    return bodies.where((p) {
      final bodyColor = _filename(p).substring(gender.length);
      return bodyColor == color;
    }).toList();
  }

  static Future<CharacterParts> generate() async {
    final assets = await _getAssets();
    final gender = _random.nextBool() ? 'male_' : 'female_';

    // Head determines the skin-tone color.
    final heads = _filterGender(assets['heads']!, gender);
    final head = _pick(heads);
    final color = _headColor(head, gender);

    // Body and face must share the same skin color.
    final bodies = _bodiesWithColor(
      _filterGender(assets['body']!, gender),
      gender,
      color,
    );
    final faces = _facesWithColor(
      _filterGender(assets['faces']!, gender),
      gender,
      color,
    );

    return CharacterParts(
      body: _pick(bodies.isNotEmpty ? bodies : assets['body']!),
      head: head,
      face: _pick(faces.isNotEmpty ? faces : assets['faces']!),
      hair: _pick(assets['hair']!),
      legs: _pick(assets['legs']!),
      torso: _pick(_filterGender(assets['torso']!, gender)),
    );
  }
}
