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
- when all players registered themself, someone can start the game and everyone can see to which team he was assigned
- each player should go to his side to start crafting
- when the game is finished, the world should be resetted to remove all items on the map and in the inventory of the players

# Rules:

- player can select a character class by crafting the right item. Players are only able to craft one item per round.
- the team which destroys the base of the opponent team first, wins.

# Things we cannot prevent

- player crafting a weak blocker, droping their crafted item in there to craft another weapon. You can use this to have multiple class-weapons
- player creating own buildings with stronger weapons
- player intentionally going to the wrong opponent team to have an advantage
