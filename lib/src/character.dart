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

class Character {
  final String firstName;
  final String lastName;
  final CharacterParts parts;

  const Character({
    required this.firstName,
    required this.lastName,
    required this.parts,
  });

  String get fullName => '$firstName $lastName';
}
