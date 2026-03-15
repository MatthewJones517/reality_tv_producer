# Reality TV Producer

![Reality TV Producer Banner](https://raw.githubusercontent.com/MatthewJones517/reality_tv_producer/refs/heads/main/wide-cover.png)

## Where to Play

The main game page is on itch:
https://makerinator.itch.io/reality-tv

If itch is blocked by your corporate proxy, you can just play it on my website:
https://realitytvproducer.makerinator.com/


## What is This?

Reality TV Producer is my submission to the 2026 Flame Game Jam. I had never participated in a game jam before, so I decided to give it a shot. 

If you're not familiar, [flame](https://flame-engine.org/) is a game engine built on top of the Flutter framework. It's awesome because you get all the cool game engine stuff, but you can just use standard Flutter for all of your UI elements. 

Each year they give you a different theme. For 2026 it was **"Big Brother"**. They also give you a choice of three modifiers. This year you could choose between:

- Game Pad Support
- No Protagonist
- Procedural Generation

The full details of the 2026 jam can be found here: https://itch.io/jam/flame-game-jam-2026

I chose the "Procedural Generation" modifier. 

## Gameplay

I've long been obsessed with arcade games, particularly redemption games and coin pushers. I had a really fun experience using the [Forge2D](https://pub.dev/packages/forge2d) package on my previous game, [FlipPuck](https://www.youtube.com/watch?v=HGx43u8oE0w&t=1s). I was curious to see how far I could push the physics. 

At any given time there are 500 - 600 individual tokens being tracked on screen. This did lead to some "creative" solutions for managing performance. Ultimately for this to run well in a browser I had to use WASM instead of Flutter's default CanvasKit. Also... You should probably be playing it in Chrome. 

There was an infamous reality TV show called [Big Brother](https://en.wikipedia.org/wiki/Big_Brother_(American_TV_series)). I never really watched it, but its pop culture influence is somewhat inescapable. While reality TV isn't necessarily my thing, I do enjoy thinking about the way things are made. How, as a producer, do you guarantee that there's enough drama in each episode to keep people interested? How do you push for ratings? 

That last thought (how do you push for ratings?) was the spark that led to Reality TV Producer. 

In this game you get a cast of four procedurally generated characters. Each one has two attributes. These can include things like "flirty" or "paranoid". 

As the game progresses, you can purchase tokens matching these attributes in the shop. You can also buy different perks that provide bonuses when these attributes interact with each other. 

While the game isn't perfect... There's definitely some bugs that need squashed and features I'd loved to have added... It's the best I could knock out before the game jam deadline. I'm fairly pleased with the result under the conditions. I think there's some neat ideas in here that, if I were inclined, could be more fully explored in a bigger game. 

I'm particiularly pleased with the procedural character generation. I used the incredible [LPC Sprite Collection](https://liberatedpixelcup.github.io/Universal-LPC-Spritesheet-Character-Generator). As a result each character feels uniquely quirky. 

## Credits

While much of the art is my original work (namely the token designs) a lot came from generous folks who have open sourced their work. I'd like to attribute their work here. 

### LPC Character Assets
As mentioned in the previous section, I used the LPC Sprite Collection. As suggested [on their GitHub](https://github.com/LiberatedPixelCup/Universal-LPC-Spritesheet-Character-Generator) I have included their [CREDITS.csv](https://github.com/MatthewJones517/reality_tv_producer/blob/main/CREDITS.csv) with the project.

### Image Assets

[TV Set by Kieff](https://opengameart.org/content/pixel-art-tv-set)

[City Background by CraftPix](https://opengameart.org/content/simple-seamless-city-pixel-art-background)

[Smoke Puff by Aidan_Walker](https://opengameart.org/content/smoke-puff)

### Music

[Spring Thing by shiru8bit](https://opengameart.org/content/8-bit-chiptune-spring-thing)

[Slam Funk by Haley Halcyon](https://opengameart.org/content/nes-chiptune-slam-funk)

[Interlude Silly by 3XBlast](https://opengameart.org/content/chiptune-interlude-pack)

### Sound Effects

[Chiptune SFX Pack by FrogPog](https://opengameart.org/content/chiptune-sfx-pack)

[Level up, power up, Coin get by Wobbleboxx](https://opengameart.org/content/level-up-power-up-coin-get-13-sounds)

[Power-Up Sound Effects by Spring Spring](https://opengameart.org/content/power-up-sound-effects)

[Won! (Orchestral winning jingle) by spuispuin](https://opengameart.org/content/won-orchestral-winning-jingle)

[gunloop 8bit by Luke.RUSTLTD](https://opengameart.org/content/gunloop-8bit)