# Tileman

## Development

To run the game on MacOS after installing LOVE: `open -n -a love "../tileman"`
To run the game on Windows after installing LOVE: `"E:LOVE\love.exe" --console "C:\Users/Chris Guilliams/Projects/tileman"`

[SUIT](https://github.com/vrld/suit) is used for UI elements

## Inspiration

- Balatro for language/framework
- Runescape Tileman challenge and leveling system
- FallenSword
- Corekeeper Automation
- Minecraft Skyblock
- Stardew Valley mine
- Atypography: [TLOCRT](https://www.atypography.com/product-page/tlocrt-h-v-sq)

## Gameplay loop

Roguelite

Character's base revolves largely around incremental/idle mechanics. Over time a character will earn things like tiles, energy, and health. 

The goal is to build up a 'run' while idling. Players would be rewarded for playing well by making the most of the resources they take on their runs.

A character must 'unlock' tiles. Each time a tile is unlocked various mechanics determine what kind of tile is generated.

### Design Goals

- Emergent world generation rewards continous exploration over time as additional upgrades are obtained
    - Example: Discover new tiles after purchasing upgrades to size/density of resource tiles
- The game is "[juicy](https://www.youtube.com/watch?v=Fy0aCDmgnxg)"

### Base

Ideally the character would move around the base to interact with various buildings/machines to enhance and upgrade idle mechanics.

Certain upgrades would be centered around taking gear on a run and setting up a machine or some other mechanic on a specific tile/floor.

### Floors

Rarer resources the lower you go.
#### Shovels

## Upgrades

- Max number of tiles that can be discovered per run
- Max number of tiles that a floor can contain
- Increase max stack size of items
- Increase backpack size
- Reduce cost scaling for tiles
- Increase max number of items retained on death
- Max energy
- Reduce respawn time for trees
- Fog of war radius
- Enemies
    - Increase max enemy health
- Shovel: Allows the character to dig to a lower floor if they reach their lowest floor
- Boat: Ability to travel over water

## Skills

- Total level
- Exploration: Gain experience when discovering tiles inversely related to their probability of being discovered
- Woodcutting: Gain experience when chopping trees