enum Perk {
  skillStopRecharge,
  rapidAutoFire,
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
    Perk.rapidAutoFire: 'Rapid Auto Fire',
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
    Perk.skillStopRecharge:
        'Skill stop meter recharges four times faster.',
    Perk.rapidAutoFire:
        'Holding down space enables rapid fire.',
    Perk.doubleThreat:
        'Flirty characters double the ratings from Charming tokens.',
    Perk.loveTriangle:
        'Jealous characters double the ratings from Flirty tokens.',
    Perk.tooEasy:
        'Scheming characters double the ratings from Oblivious tokens.',
    Perk.marketingBudget:
        'Every coin pushed over provides a small ratings boost.',
    Perk.didYouHearAbout:
        'Chatty characters double the ratings from Nosy tokens.',
    Perk.theMole:
        'Loyal characters double the ratings from Scheming tokens.',
    Perk.theyreDefinitelyOntoMe:
        'Paranoid characters double the ratings from Oblivious tokens.',
    Perk.theFeelingIsMutual:
        'Flirty and Jealous characters double ratings for each other.',
    Perk.crickets:
        'Chatty characters double the ratings from Stoic tokens.',
    Perk.memeLord:
        '5% chance to 10x a token’s ratings value when it falls.',
  };

  String get description => descriptions[this]!;
}
