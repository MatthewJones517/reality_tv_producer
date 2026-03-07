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

  /// Body format: `{gender}_{color}` → strip gender prefix.
  static String _bodyColor(String path, String gender) =>
      _filename(path).substring(gender.length);

  /// Head format: `{gender}[_plump]_head_{color}` → everything after `_head_`.
  static String _headColor(String path) {
    final name = _filename(path);
    const marker = '_head_';
    final idx = name.indexOf(marker);
    return name.substring(idx + marker.length);
  }

  /// Face format: `{gender}_{expression}_{color}` → everything after first `_`
  /// past the gender prefix (expression is always one token).
  static String _faceColor(String path, String gender) {
    final rest = _filename(path).substring(gender.length);
    return rest.substring(rest.indexOf('_') + 1);
  }

  static Future<CharacterParts> generate() async {
    final assets = await _getAssets();
    final gender = _random.nextBool() ? 'male_' : 'female_';

    // Body determines the skin-tone color (simplest naming scheme).
    final bodies = _filterGender(assets['body']!, gender);
    final body = _pick(bodies);
    final color = _bodyColor(body, gender);

    // Head and face must share the same skin color.
    final heads = _filterGender(assets['heads']!, gender)
        .where((p) => _headColor(p) == color)
        .toList();
    final faces = _filterGender(assets['faces']!, gender)
        .where((p) => _faceColor(p, gender) == color)
        .toList();

    return CharacterParts(
      body: body,
      head: _pick(heads.isNotEmpty ? heads : _filterGender(assets['heads']!, gender)),
      face: _pick(faces.isNotEmpty ? faces : _filterGender(assets['faces']!, gender)),
      hair: _pick(assets['hair']!),
      legs: _pick(assets['legs']!),
      torso: _pick(_filterGender(assets['torso']!, gender)),
    );
  }
}
