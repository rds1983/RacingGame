## XNA-4-Racing-Game-Kit
Port of [XNA-4-Racing-Game-Kit](https://www.moddb.com/downloads/xna-40-racing-game-starter-kit) to MonoGame/FNA.
![image](https://github.com/user-attachments/assets/1c3a4808-4ea3-4ce5-8f28-cf771a38a18a)

The port doesn't use Content Pipeline, but loads all assets in raw form using [XNAssets](https://github.com/rds1983/XNAssets).
All game 3d models are loaded from glb.

## Building From Source Code for MonoGame
Open RacingGame.MonoGameDX.sln in the IDE and run.

## Building From Source Code for FNA

Clone following repos in one folder:
Link|Description
----|-----------
https://github.com/FNA-XNA/FNA|FNA
https://github.com/rds1983/DdsKtxSharp|Loading textures in DDS format
https://github.com/rds1983/XNAssets|Asset management library
https://github.com/rds1983/DigitalRiseModel|3D model library
this repo|

Then simply open RacingGame.FNA.Core.sln in the IDE and run.


