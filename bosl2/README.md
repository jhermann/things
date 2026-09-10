# BOSL2 Examples

Using OpenSCAD together with the BOSL2 library.

**Links**

- [Belfry OpenSCAD Library v2](https://github.com/BelfrySCAD/BOSL2/wiki#belfry-openscad-library-v2) (BOSL2)
- [BOSL2 Function Cheat Sheet](https://github.com/BelfrySCAD/BOSL2/wiki/Topics)
- [MakerWorld PMM OpenSCAD Reference](https://nelsonjchen.github.io/unofficial-makerworld-parametric-model-maker-openscad-docs/) (unofficial, [GitHub][gh-mw-pmm-docs])

**Models**

> ![Tiled Preview](./preview.png)

- [basic-bosl2.scad](./basic-bosl2.scad) - Minimal BOSL2 example that attaches a cylinder to the top face of a cuboid using `attach()`. [🧊✏️][mw-basic-bosl2]
- [attach.scad](./attach.scad) - Demonstrates BOSL2 anchors and `attach()` by cutting an attached countersunk hole into a box.
- [holes-grid.scad](./holes-grid.scad) - Perforated plate with a configurable rounded outline, chamfered edges, and repeated beveled holes. [🧊✏️][mw-holes-grid]
- [name-plate.scad](./name-plate.scad) - Configurable rounded name plate with recessed text. [🧊✏️][mw-name-plate]
- [texture-brushed-metal.scad](./texture-brushed-metal.scad) - Demonstrates a brushed-metal texture applied to OpenSCAD geometry. <br /><br /> ![printed](./texture-brushed-metal.jpg) <br /> *Red Copper PLA • rows 30 • cols 20 • depth 0.25*
- [texture-rough.scad](./texture-rough.scad) - Demonstrates the built-in rough texture applied to a cylindrical print. <br /><br /> ![printed](./texture-rough.jpg) <br /> *Red Copper PLA • size 5×55 • depth 0.15*
- [textures.scad](./textures.scad) - Demonstrates built-in and custom BOSL2 textures on cylindrical and swept geometry.
- [threads.scad](./threads.scad) - Flush threaded container and lid with a shared trapezoidal thread profile and ribbed grip. [🧊✏️][mw-threads]


[mw-basic-bosl2]: https://makerworld.com/en/makerlab/parametricModelMaker?from=model_page&modelName=basic-bosl2.scad&scadUrl=https%3A%2F%2Fraw.githubusercontent.com%2Fjhermann%2Fthings%2Frefs%2Fheads%2Fmain%2Fbosl2%2Fbasic-bosl2.scad
[mw-holes-grid]: https://makerworld.com/en/makerlab/parametricModelMaker?from=model_page&modelName=holes-grid.scad&scadUrl=https%3A%2F%2Fraw.githubusercontent.com%2Fjhermann%2Fthings%2Frefs%2Fheads%2Fmain%2Fbosl2%2Fholes-grid.scad
[mw-name-plate]: https://makerworld.com/en/makerlab/parametricModelMaker?from=model_page&modelName=name-plate.scad&scadUrl=https%3A%2F%2Fraw.githubusercontent.com%2Fjhermann%2Fthings%2Frefs%2Fheads%2Fmain%2Fbosl2%2Fname-plate.scad
[mw-threads]: https://makerworld.com/en/makerlab/parametricModelMaker?from=model_page&modelName=threads.scad&scadUrl=https%3A%2F%2Fraw.githubusercontent.com%2Fjhermann%2Fthings%2Frefs%2Fheads%2Fmain%2Fbosl2%2Fthreads.scad
[gh-mw-pmm-docs]: https://github.com/nelsonjchen/unofficial-makerworld-parametric-model-maker-openscad-docs/tree/main
