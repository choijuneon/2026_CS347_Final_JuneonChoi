# 2026_CS347_Final_JuneonChoi
2026 UW-Stout CS347 Final godot scene by Juneon Choi 

## Overview
This project focuses on implementing shaders and environmental VFX using the Godot Engine, developed as part of the UW–Stout CS347 final.

I worked on enhancing the visual quality of the level by creating custom shaders, particle systems, and lighting setups.

## What did I do
- Created and placed textured light poles along the track
- Used Voxel global illumination
- Developed custom lava and water shaders using Godot Shader Language
- Implemented a bubble shader and a wobble shader for collectible items
- Built multiple particle systems:
  - Volcano meteors
  - Confetti effects
  - Waterfall bubbles
- Created shader-based particle effects (e.g., volcano smoke)
- Applied post-processing and skybox using `WorldEnvironment`

## What I Learned
- Writing real-time shaders in Godot Shader Language
- Integrating shaders with particle systems
- Balancing visual quality with performance in a game environment

## Tech Demo Video
- 15 Sec Tech Demo for SGX  
https://youtu.be/o1DGaE6cfyA

## Notes
This project was integrated into a team GDD 325 game project.  
  
Due to inter-file dependencies, the project structure is not fully cleaned or modularized.  
However, all implemented features can be tested directly within the main scene.  
The scene's name is `FinalMainScene.tscn`, and it's already set as main scene.

## How to Run
1. Open the project in Godot 4.4
2. Load the scene: `FinalMainScene.tscn`
3. Run the scene (already set as the main scene)
4. Check the samples of particles and shaders at the starting point
5. Explore the scene further with the bike controller (use WASD to move)

## Credits

### Assets

- Meshes for the volocano terrain meshes, tracks by Driven  
by Driven to Madness Team artists Mia Hazen and Stephan Halverson

- Citrus Orchard Road (Pure Sky) HDRI from Poly Heaven  
https://polyhaven.com/a/citrus_orchard_road_puresky

- Smoke noise Texture by Le Lu  
https://drive.google.com/drive/folders/120SVV_XnKT69Riy1C5Bb6BcaVJ6lGAQm

### Tutorials

- Godot Water Shader Tutorial by StayAtHomeDev  
https://youtu.be/7L6ZUYj1hs8?si=XxxzFVuGYDeMjcl3

- Godot Bubble Shader by Pefeper  
https://youtu.be/sj4BeJKhe_Y?si=clBbwBpkadtBRz9A

- Godot Smoke Particle tutorial by Le Lu  
https://youtu.be/e_6ZA-xa_DQ?si=hE_4nOn66oGXwV3d

- Godot Lightmap / Voxel GI Tutorial by Gwizz  
https://youtu.be/7GH9UL_8eME?si=L7GB2MPpb-ODbtQM
