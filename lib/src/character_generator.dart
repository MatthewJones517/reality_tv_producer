import 'dart:math';

import 'package:flutter/services.dart';

import 'character.dart';

const _firstNames = [
  'Alex', 'Avery', 'Bailey', 'Blake', 'Blair', 'Brett', 'Briar', 'Brooklyn',
  'Cameron', 'Casey', 'Charlie', 'Chase', 'Clay', 'Cole',
  'Dakota', 'Dallas', 'Dana', 'Darcy', 'Devon', 'Drew', 'Dylan',
  'Eden', 'Elliot', 'Ellis', 'Emerson', 'Emery', 'Evan',
  'Finley', 'Flynn', 'Frankie',
  'Gray', 'Greer',
  'Harper', 'Harley', 'Hayden', 'Hunter',
  'Indigo',
  'Jace', 'Jamie', 'Jesse', 'Jordan', 'Jules', 'Juniper', 'Justice',
  'Kai', 'Kendall', 'Kennedy', 'Kerry', 'Kieran',
  'Lake', 'Lane', 'Laurie', 'Lee', 'Lennon', 'Logan', 'Luca', 'Lynn',
  'Marlowe', 'Mason', 'Maxine', 'Merritt', 'Mickey', 'Milan', 'Morgan',
  'Murphy',
  'Nash', 'Nico', 'Noel', 'Nova',
  'Oakley',
  'Parker', 'Payton', 'Phoenix', 'Pierce', 'Piper',
  'Quinn',
  'Reese', 'Remy', 'Riley', 'River', 'Robin', 'Rowan',
  'Sage', 'Sam', 'Scout', 'Shawn', 'Shiloh', 'Sidney', 'Skyler', 'Sloane',
  'Spencer', 'Sterling', 'Stevie', 'Story', 'Sutton',
  'Tatum', 'Taylor', 'Tegan',
  'Wren',
  'Zion',
];

const _lastNames = [
  'Abbott', 'Acosta', 'Adler', 'Aldridge', 'Allison', 'Archer', 'Ashford',
  'Atwood',
  'Banks', 'Barlow', 'Barrett', 'Beckett', 'Bell', 'Bennett', 'Bishop',
  'Blackwood', 'Blake', 'Bloom', 'Bolton', 'Booker', 'Briggs', 'Brooks',
  'Buchanan', 'Burke', 'Burns',
  'Calloway', 'Canton', 'Carver', 'Castle', 'Chase', 'Clayton', 'Clifton',
  'Cole', 'Collins', 'Conrad', 'Conway', 'Crane', 'Cross',
  'Dalton', 'Davenport', 'Drake', 'Duffy', 'Duncan', 'Dunne',
  'Easton', 'Ellis', 'Emerson', 'Everett',
  'Fairbanks', 'Finch', 'Fisher', 'Fletcher', 'Flynn', 'Foster', 'Fox',
  'Garrett', 'Gibbs', 'Gilmore', 'Grant', 'Graves', 'Greene', 'Griffin',
  'Hale', 'Hammond', 'Harlow', 'Hart', 'Hawkins', 'Hayes', 'Holloway',
  'Holmes', 'Hudson', 'Hunt', 'Huxley',
  'Ingram', 'Irons',
  'Kane', 'Keating', 'Kelley', 'Kent', 'Kimball', 'Kingsley', 'Knox',
  'Langley', 'Lawson', 'Leighton', 'Lennox', 'Lowe',
  'Marsh', 'Mercer', 'Monroe', 'Moss',
  'Nash', 'Nolan', 'Norris',
  'Oakes',
  'Parrish', 'Pearce', 'Pendleton', 'Perry', 'Pierce',
];

const _funFacts = [
  'Once ate an entire taco in one bite',
  'Obsessed with dwarves',
  'Played video games for 20 hours straight without a bathroom break',
  'Cries at every dog food commercial',
  'Has never successfully assembled IKEA furniture',
  'Convinced their houseplant understands English',
  'Once got lost in a Costco for three hours',
  'Eats cereal with orange juice instead of milk',
  'Has a framed photo of a celebrity they\u0027ve never met on their mantle',
  'Knows every word to the Shrek soundtrack',
  'Sleeps with exactly seven pillows',
  'Once microwaved a fork on purpose just to see what happened',
  'Refers to their car by a first name',
  'Has an irrational fear of escalators',
  'Collects novelty bottle openers',
  'Once entered a hot dog eating contest and came in last by a significant margin',
  'Genuinely believes they can communicate with pigeons',
  'Has never seen a single Star Wars film and is proud of it',
  'Owns more than forty sets of novelty socks',
  'Once got a tattoo while on vacation and won\u0027t say what it is',
  'Convinced their neighbours are secretly famous',
  'Has memorised the entire menu of a restaurant that closed in 2009',
  'Cried at a furniture commercial',
  'Licks the bowl after every meal regardless of company',
  'Once bet their car on a coin flip',
  'Refuses to eat green M&Ms on principle',
  'Has a detailed conspiracy theory about seagulls',
  'Takes notes during cartoons',
  'Once fell asleep at their own birthday party',
  'Insists on narrating their own life in third person when nervous',
  'Has never successfully winked',
  'Genuinely prefers the smell of old books to most foods',
  'Once trained a squirrel to take crackers from their hand and considers it their greatest achievement',
  'Keeps a spreadsheet ranking every sandwich they\u0027ve ever eaten',
  'Has an opinion about every font',
  'Once challenged a child to an arm wrestle and lost',
  'Refers to napping as "horizontal life evaluation"',
  'Has a lucky spoon they bring to important events',
  'Once wrote a strongly worded letter to a cereal brand and got a coupon back',
  'Convinced that one specific cloud follows them',
  'Has memorised the nutritional info on a specific brand of crackers',
  'Once tried to return something to a store nineteen years after purchase',
  'Owns a karaoke machine they\u0027ve never used',
  'Has a nemesis at the local trivia night',
  'Once mispronounced a word so badly it became a family legend',
  'Keeps a journal written entirely in self-invented shorthand',
  'Genuinely believes they invented a dance move that already existed',
  'Once got into an argument with a GPS and pulled over to make their point',
  'Has a strong and unprompted opinion about roundabouts',
  'Sleeps with one foot outside the covers at all times',
  'Once ate an entire wedding cake tier before the ceremony',
  'Has never lost a staring contest with an animal',
  'Refers to Tuesdays as "the worst Monday"',
  'Once cried in a hardware store and won\u0027t explain why',
  'Keeps emergency snacks in eight different locations',
  'Has a signature walk that others have tried and failed to replicate',
  'Once got a standing ovation at a karaoke bar for a song they made up on the spot',
  'Genuinely believes they have a sixth sense for finding parking',
  'Has named every spider in their house',
  'Once convinced an entire flight the pilot was their cousin',
  'Measures time in episodes of their favourite show',
  'Has an autograph from someone they cannot identify',
  'Once won a trophy and still doesn\u0027t know what it was for',
  'Refers to breakfast as "the opening ceremony"',
  'Has a recurring dream about competitive cheese rolling',
  'Once spent forty-five minutes arguing with a vending machine',
  'Genuinely believes their blood type affects their personality',
  'Has a nemesis who doesn\u0027t know they exist',
  'Once entered a raffle, forgot about it, and won a boat',
  'Collects menus from restaurants they\u0027ve never visited',
  'Has a formal ranking system for clouds',
  'Once stress-baked forty-seven muffins and gave them to strangers',
  'Refuses to acknowledge daylight saving time on principle',
  'Has a detailed origin story for every scar, most of which are fabricated',
  'Once made a vision board that accidentally predicted three things correctly',
  'Genuinely believes they are better at parallel parking than they are',
  'Has a dedicated playlist for doing laundry',
  'Once got a standing ovation from pigeons and has never recovered',
  'Keeps a list of every person who has ever beaten them at mini golf',
  'Considers themself an expert on a topic they read one article about',
  'Has a strong opinion about the correct way to eat a Kit Kat',
  'Once fell into a fountain while looking at their phone and kept walking',
  'Names their houseplants after historical figures',
  'Has a running feud with a specific self-checkout machine',
  'Once accidentally joined a flash mob and just went with it',
  'Genuinely convinced their cooking show would be a hit',
  'Has an opinion about the best fictional president',
  'Once fell asleep during a movie they chose and said it was "fine"',
  'Refers to going to bed as "filing the day away"',
  'Has a specific order for eating every meal that cannot be disrupted',
  'Once made eye contact with a horse and felt understood',
  'Considers their parking spot selection a form of self expression',
  'Has memorised the layout of every Ikea they\u0027ve ever entered',
  'Once answered the phone in an accent by accident and had to maintain it for twenty minutes',
  'Keeps a mental log of every time they\u0027ve been right in an argument',
  'Has a personal vendetta against a specific brand of pen',
  'Once fell asleep standing up and considers it their proudest physical achievement',
  'Refers to their couch as "the office"',
  'Genuinely believes they can tell time without a clock and is consistently wrong by two hours',
  'Once narrated their own grocery run as a nature documentary out loud and got applause',
];

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

  static Future<Character> generate() async {
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

    final shuffled = List.of(Attribute.values)..shuffle(_random);
    final attributes = shuffled.take(2).toList();

    return Character(
      firstName: _pick(_firstNames),
      lastName: _pick(_lastNames),
      attributes: attributes,
      funFact: _pick(_funFacts),
      parts: CharacterParts(
        body: body,
        head: _pick(
          heads.isNotEmpty ? heads : _filterGender(assets['heads']!, gender),
        ),
        face: _pick(
          faces.isNotEmpty ? faces : _filterGender(assets['faces']!, gender),
        ),
        hair: _pick(assets['hair']!),
        legs: _pick(assets['legs']!),
        torso: _pick(_filterGender(assets['torso']!, gender)),
      ),
    );
  }
}
