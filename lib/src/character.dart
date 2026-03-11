enum Attribute {
  flirty,
  nosy,
  loyal,
  competitive,
  oblivious,
  vindictive,
  charming,
  paranoid,
  chatty,
  stoic,
  scheming,
  forgetful,
  jealous,
  generous,
  grudgeHolder;

  static const labels = {
    flirty: 'Flirty',
    nosy: 'Nosy',
    loyal: 'Loyal',
    competitive: 'Competitive',
    oblivious: 'Oblivious',
    vindictive: 'Vindictive',
    charming: 'Charming',
    paranoid: 'Paranoid',
    chatty: 'Chatty',
    stoic: 'Stoic',
    scheming: 'Scheming',
    forgetful: 'Forgetful',
    jealous: 'Jealous',
    generous: 'Generous',
    grudgeHolder: 'Grudge-holder',
  };

  String get label => labels[this]!;
}

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
  final List<Attribute> attributes;
  final String funFact;
  final CharacterParts parts;

  const Character({
    required this.firstName,
    required this.lastName,
    required this.attributes,
    required this.funFact,
    required this.parts,
  });

  String get fullName => '$firstName $lastName';
}
