# Basic 3D Character Controller for Godot
<img width="1845" height="1064" alt="godotnaut" src="https://github.com/user-attachments/assets/44365c51-58fd-443d-ae0d-f695d8ffda16" />

## Features
A simple 3D third person character controller, with a fully functional (but independent) third person camera. 

<img width="955" height="716" alt="general" src="https://github.com/user-attachments/assets/96af724d-c559-4252-8c60-23c2c85f7f9a" />

A simple state machine that manages animations, running, and rolling. 

<img width="959" height="719" alt="run" src="https://github.com/user-attachments/assets/d53ef6cb-8a45-45b4-82c2-81d31d95597a" />

Customisable settings in the editor: 
```
- move speed            # How fast the player moves
- run speed             # How fast the player runs
- roll speed            # How fast the player rolls
- jump velocity         # How high the player jumps
- turn scalar           # How fast the player turns
- turn immediate        # Multiplier for the player's turn.
- accelerate immediate  # Multiplier for the player's acceleration.
- decelerate immediate  # Multiplier for the player's deceleration.
- variable jump         # Multiplier for the player's jump input.
```

<img width="1280" height="720" alt="settings" src="https://github.com/user-attachments/assets/1d7e3ada-c0d1-4078-8953-b6089340505b" />

To use the camera, simply drag the `camera.tsc` into your scene and use the `set_following` function. 

For example, inside the player's `_ready` event, you could call:
```
set_following(self)
```
To alter its third person properties such as distance from player and offset, change its Spring Arm. 

<img width="1280" height="720" alt="camera" src="https://github.com/user-attachments/assets/1e7e4227-43a8-47e6-84b3-e2dc66afd366" />

Check out `player.gd` and `camera.gd` to view the fully documented code. 

## Credits
- Block texture adapted from Kenney's [Prototype Textures asset pack](https://www.kenney.nl/assets/prototype-textures).
- Godotnaut was rigged and animated using [Mesh2Motion](https://mesh2motion.org/).
- Demo project was created with the [Godot game engine](https://godotengine.org/).
