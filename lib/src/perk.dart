import 'character.dart';

enum Perk {
  skillStopRecharge,
  doubleThreat,
  loveTriangle,
  tooEasy,
  marketingBudget,
  didYouHearAbout,
  theMole,
  theyreDefinitelyOntoMe,
  theFeelingIsMutual,
  crickets,
  memeLord;

  static const labels = {
    Perk.skillStopRecharge: 'Skill Stop Recharge',
    Perk.doubleThreat: 'Double Threat',
    Perk.loveTriangle: 'Love Triangle',
    Perk.tooEasy: 'Too Easy',
    Perk.marketingBudget: 'Marketing Budget',
    Perk.didYouHearAbout: 'Did You Hear About...?',
    Perk.theMole: 'The Mole',
    Perk.theyreDefinitelyOntoMe: "They're Definitely Onto Me",
    Perk.theFeelingIsMutual: 'The Feeling Is Mutual',
    Perk.crickets: 'Crickets',
    Perk.memeLord: 'Meme Lord',
  };

  String get label => labels[this]!;

  static const descriptions = {
    Perk.skillStopRecharge: 'Skill stop meter recharges four times faster.',
    Perk.doubleThreat:
        'Two people work the room at the same time. Flirty characters double the ratings from Charming tokens.',
    Perk.loveTriangle:
        'Someone\'s making moves and someone else noticed. Jealous characters double the ratings from Flirty tokens.',
    Perk.tooEasy:
        'The perfect target has been selected. Scheming characters double the ratings from Oblivious tokens.',
    Perk.marketingBudget:
        'Every coin pushed over provides a small ratings boost.',
    Perk.didYouHearAbout:
        'The gossip pipeline is open for business. Chatty characters double the ratings from Nosy tokens.',
    Perk.theMole:
        'Betraying the one person who trusts you. Scheming characters double the ratings from loyal tokens.',
    Perk.theyreDefinitelyOntoMe:
        'They\'re not. They\'re thinking about sandwiches. Paranoid characters double the ratings from Oblivious tokens.',
    Perk.theFeelingIsMutual:
        'Both are watching each other. Neither knows why. Nosy and Paranoid characters double ratings for each other.',
    Perk.crickets:
        'One talks. One stares. America is obsessed. Chatty characters double the ratings from Stoic tokens.',
    Perk.memeLord:
        'You\'re on TikTok! 5% chance to 10x a token’s ratings value when it falls.',
  };

  String get description => descriptions[this]!;

  /// Token attributes that must be unlocked for this perk to have any effect.
  /// Empty means the perk works without any token purchases.
  static const requiredTokens = <Perk, List<Attribute>>{
    Perk.doubleThreat: [Attribute.charming],
    Perk.loveTriangle: [Attribute.flirty],
    Perk.tooEasy: [Attribute.oblivious],
    Perk.didYouHearAbout: [Attribute.nosy],
    Perk.theMole: [Attribute.scheming],
    Perk.theyreDefinitelyOntoMe: [Attribute.oblivious],
    Perk.theFeelingIsMutual: [Attribute.nosy, Attribute.paranoid],
    Perk.crickets: [Attribute.stoic],
  };

  /// Returns true if this perk can be offered (all required tokens are unlocked).
  static bool isEligible(Perk perk, Map<Attribute, int> unlockedTokens) {
    final required = requiredTokens[perk];
    if (required == null || required.isEmpty) return true;
    return required.every((attr) => (unlockedTokens[attr] ?? 0) > 0);
  }
}
