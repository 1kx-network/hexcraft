# installation

To play the game, you need to install the required buildings into the instance. To do this, please execute

```
sh ./deploy.sh <instance> <private key>
```

To generate the map, you can use the file `map/map.yaml`. All custom buildings and their placements are defined in there.

# setup

- reset the game instance to get a fresh state of everything
- install the game specific buildings
- set the tiles and buildings with `map/map.yaml`

# starting the game

- all players should go to the Headquarter bottom center, to register themself to the game
- when all players registered themself, someone can start the game and everyone can see to which team he is assigned
- each player should go to his side to start crafting
- when the game is finished, the world should be resetted to remove all items on the map and in the inventory of the players

# Rules:

- player can select a character class by crafting the right item. Player are only able to craft one item per round.
- player can craft a `Crafting Hammer`, to build additional buildings: `Barrier` and `Cannon`. They can be placed near the opponent base to strength your attack, when you start your attack from the same tile. To build a `Barrier` or `Cannon`, you need a `Crafting Hammer` in your inventory, which get's consumed.
- the team which destroys the base of the opponent team first, wins.
- To be strong enought to destroy a base, you should at least attack with 2 players and a building.

