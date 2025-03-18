## Project Overview

Name: Tileman
Genre: Incremental, Idle

### High-level vision and goals (similar to what you have in your README.md)
- As a character that starts with nothing but a single tile to stand on you are tasked with finding ways to generate experience and resources through various means. As your knowledge increases and you explore more of the world additional options and strategies open up to you to increase the rate at which you can generate experience and resources. 
- Critical achievements within skills will open up avenues for passive experience and resource generation
- A player should be rewarded for exploring previously undiscovered portions of the world.

### Core gameplay loop description
- The character starts on a single `Grass` tile. They are able to see the tiles touching the tiles they are standing on but are not able to interact with or move to other tiles until they have unlocked them.
- Different tile types exist but not all are able to be generated when exploring the world initially. Through gameplay progression new or improved tile types will be unlocked. 
- For a character to unlock additional tiles to move to certain conditions must be met. These conditions can vary, but generally tile unlocks will be granted when a certain amount of total experience has been gained.
- The character will have certain skills which can gain experience. Total experience will track all of the experience they have gained in all of their skills.
- Skills will increase in level when a certain amount of experience is gained in that skill. The amount of experience required to level up a skill will increase as that skills level increases.
- Actions related to skills will cause the character to gain experience in that skill.
- Various upgrades will become available as skills increase in level. It is expected that these upgrades will make it easier to generate more experience through new mechanics or by increasing the amount or rate of experience gained by various actions.
- Some skills will require performing actions on a specific tile type. Such as a tree for woodcutting or water for fishing.

### Target audience and platform
- People familiar with incremental games. 
- This game should be available for distribution to desktop PC's as well as the web.

## Design Principles
### Document your key design philosophies (like your "juicy" gameplay goal)
- [Juicy](https://www.youtube.com/watch?v=Fy0aCDmgnxg)
### List non-negotiable requirements
### Define your design constraints

## Technical Requirements
### Framework/engine requirements (LÖVE in your case)
- Lua using LÖVE2D
### Performance targets
### Platform-specific considerations
### Third-party dependencies 
- [SUIT](https://github.com/vrld/suit) - Menus, buttons
- [flux](https://github.com/rxi/flux) - Tweening values for animations

## Feature Specifications
### Break down each major system with:
### Purpose and goals
### Detailed mechanics
#### Tile types
- Types: Grass, Water, Tree, Stone
#### Skills
- Melee: Gained when damaging an enemy when using a melee weapon. Increases to this skill increase the characters ability to deal damage with melee weapons.
- Ranged: Gained when damaging an enemy when using a ranged weapon. Increases to this skill increase the characters ability to d eal damage with ranged weapons.
- Defense: Gained when being damaged by enemies. Increases to this skill reduce the damage a character takes when being damaged. 
- Magic: Gained when casting spells. Increases to this skill unlocks new spells.
- Mining: Gained when mining resources. Increases to this skill 
- Smelting
- Agriculture
- Woodcutting
- Barter
- Knowledge
- Hunting
#### Upgrades
- For each skill: reduce tick rate for gaining experience, increase amount of experience gained, reduce scaling factor of experience required for increasing skill level
#### Tasks
#### Automation
- While not initially avaiable, once certain skill thresholds are met additional gameplay mechanics will be introduced that enable the passive generation of experience of certain skills. 
### Expected behaviors
### Integration points with other systems
### For your game, this might include:
### Tile system mechanics
- Quality: Initially all discovered tiles will have no quality. Gameplay progression will enable upgrades that allow a chance for newly discovered tiles to be generated with a higher quality. This will be random but further gameplay progression will make higher quality tiles more common as well as introduce mechanics to be able to manually increase the quality of certain tile types.
- Density: 
    - All tile types will have a variance in their density. This will impact related actions, experience gain, and resource generation for those tiles. Initially the variance in distance will be minimal and not have a large impact on gameplay. Upgrades and skill proficiency will increase the variance of the density of certain tile types as well as the degree to which the player benefits from the increased density.
    - Certain tile types will receive density bonuses when multiple of the same tile type spawn near one another. Initially it will be rare that tiles of the same type spawn near one another as they will be rare to begin with. Over time upgrades will increase the chance of this happening. The goal being rewarding the player for exploring new tiles and discovering 'hot spots' for certain skilling or resource gathering.
- Resource type: Certain tile types will have a specific resource type associated with them. Such as a `Tree` tile having `Oak` as a resource or a `Stone` tile having `Coal` as a resource. Similar to how additional tile types are unlocked so will new resource types for certain tiles.
### Character progression
- All skills start at level `1`
- All skills initially require identical amounts of experience in order to level up. As the character progresses and upgrades to skills are unlocked the amount of experience required to level certain skills will begin to deviate from one another.
### Resource management
### Building/base mechanics
### Combat system (if any)

## Visual and UI Style Guide
- Pixel art simple polygons
### Art direction
### UI/UX principles
- Menus should be presented in a similar manner across the application. 
- When possible the same sizing and layouts should be used whenever lists of information or upgrades are displayed.
- If an action or upgrade require a certain criteria to be met and that criteria is not currently met then that action or upgrade be disabled an visually appear as disabled.
### Animation guidelines
- Actions taken by the player should result in visual feedback. Visual feedback will scale based on how effective of an action was. The effectiveness of an action will be determined by the impact the generated experience had in progressing the characters skills. 
### Color palette
### Typography choices

## Data Structures and Systems
### Document how you want core systems structured:
### Save/load system requirements
- Things that should be saved: core game state (skills, experience, upgrades, resources), generated world, position of entities
### Player data structure
- Skills
- Gathered resources
### World generation parameters
- To start the only tile type that will be able to be generated or discovered is `Grass`.
- As additional tile types are unlocked the character will be able to discover previously unseen tiles to have a chance of generating the new or improved tile type.
- Some tile types will have a quality factor or level. Upgrades will allow better tile types to be generated moving forward. This will encourage the player to generate additional tiles over time and reward them with easier resource generation or experience gain for their skills.
### Upgrade system structure

## Development Priorities
### Feature implementation order
### MVP (Minimum Viable Product) definition
### Future expansion plans

## Edge Cases and Constraints
### Known limitations
### How to handle specific scenarios
### Performance boundaries