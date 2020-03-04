# Broken Engine by Broken Gem Studio
A 3D Game Engine developed by students of CITM-Barcelona for 3rd year's project 3 subject

## TOOLS USED

- Microsoft Visual Studio 2019 
- 3rd Party Libraries used:
- SDL 2.0.10
- Assimp 3.3
- Glad 0.1.33
- ImGui 1.72b (with beta docking)
- ImGuizmo
- MathGeoLib 1.5 (commit 1994)
- OpenGL 4.4
- mmgr
- par_shapes at commit 281 
- DevIL 1.8.0
- JSON for Modern C++
- PhysFS 


## HOW TO USE

There is no formal installation process, just look around and play with it

- Navigation:

Mouse and Keyboard controls are enabled both on UI and Scene, working on focused window only.

- Mouse picking

Self-explainable, click on an object to select it, notice how inspector info changes, but if the object is hidden
in the hierarchy you won't notice it there, open parent to see how it is selected.

- Scene Camera:

- Right Mouse button enables Look Around
- Alt + Left Mouse button enables Camera Orbit
- Mouse Wheel click enables camera Pan
- Right Mouse button + WASD enables free movement
- Mouse Wheel movement enables zoom

Editor camera only works when in AppState EDITOR mode.

- Guizmo:

- Move: Q
- Rotate: E
- Scale: R

## ASSET IMPORT

Drop it into the scene, done!

## DEBUG

- Debug Features

Game Objects - Redo Octree whenever you make some elements non-static and want it to be recalculated

Head to Scene window and click DebugDraw to see available features: 

- Wireframe
- Color Material
- OpenGL Lighting
- Display Octree
- Show AABBS
- ZDrawer

There are more options in Window - > Settings

## Features in beta

- Edit Menu
- Load/Save cameras

## CHANGELOG


## License:

MIT License

Copyright (c) 2019 Aitor Simona Bouzas

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


