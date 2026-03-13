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
}
