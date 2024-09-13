## XNA-4-Racing-Game-Kit
=====================

Port of [XNA-4-Racing-Game-Kit](https://www.moddb.com/downloads/xna-40-racing-game-starter-kit) to MonoGame/FNA.
![image](https://github.com/user-attachments/assets/1c3a4808-4ea3-4ce5-8f28-cf771a38a18a)

The port doesn't use Content Pipeline, but loads all assets in raw form using [XNAssets](https://github.com/rds1983/XNAssets).
All game 3d models are loaded from glb.


## Building From Source Code for FNA

Clone following repos in one folder:
* [FNA](https://github.com/FNA-XNA/FNA)
* [DdsKtxXna](https://github.com/rds1983/DdsKtxXna)
* [FontStashSharp](https://github.com/FontStashSharp/FontStashSharp)
* [XNAssets](https://github.com/rds1983/XNAssets)
* This repo

Then simply open RacingGame.FNA.Core.sln in the IDE and run.


