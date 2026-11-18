# things
Models for 3D printing, mostly OpenSCAD.

## What's in this repo?

### Models

- [AC Bayonet Connectors](models/ac-bayonet-connectors/README.md) - Quick-release bayonet connectors for joining AC hoses and attaching them to devices or window adapters.
- [AC Drain Pan](models/ac-drain-pan/README.md) - A parametric condensate drain pan for draining a portable air conditioner before transport or storage.
- [AC Hose Connector Intake](models/ac-hose-connector-intake/README.md) - Window and door panel connectors for AC intake and exhaust hoses, including an intake insect screen and an exhaust deflection cover.
- [AC Intake Cover Side Extension](models/ac-intake-cover-side-extension/README.md) - A parametric side extension box for adapting an AC intake cover to a wider or rounded device.
- [Clothes Pin](models/clothes-pin/README.md) - A single-piece, spring-free parametric clothespin.
- [Connectagon](models/connectagon/README.md) - A hollow hexagonal tile with rib and groove connectors that interlocks in a honeycomb pattern.
- [Eye Drops Holder](models/eye-drops/README.md) - A simple holder for eye-drop bottles.
- [japandi](models/japandi/README.md) - Minimalist desk accessories, including a cylindrical pen holder with a filleted inner floor, a rounded tray, and a pyramidal candle holder.
- [Lamp Base for a LED Puck](models/lamp-led-puck/README.md) - A support-free parametric lamp base for an LED puck light.
- [Sample OpenSCAD model](models/sample.scad) - A small example model for experimenting with OpenSCAD. [🧊✏️][mw-sample]

See the [complete model index](models/README.md) for the collection overview.


### Topics

- [Examples](examples/README.md) - Small, reusable OpenSCAD reference models and MakerWorld plate-template examples.
- [BOSL2 examples](bosl2/README.md) - OpenSCAD examples using the BOSL2 library.
- [Joining parts](parts/joining/README.md) - Reusable geometries for joining printed pieces, including grip fins, square dowels, and sturdy plugs.
- [Textures](parts/textures/README.md) - Reusable surface texture patterns and examples.

### Parts

- [Disks and washers](parts/disks-and-washers.scad) - Approximates a solid of revolution as stacked disks/washers using the disk/washer method. [🧊✏️][mw-disks-and-washers]
- [Hull](parts/hull.scad) - Examples of `hull()`: a stadium plate, a hollow square-to-round adapter, and a bracket blending a base into an offset post. [🧊✏️][mw-hull]
- [Rounded cubes](parts/rounded-cubes.scad) - OpenSCAD examples and modules for cubes with rounded and chamfered edges. [🧊✏️][mw-rounded-cubes]
- [Shells](parts/shells.scad) - Approximates a solid of revolution as stacked cylindrical shells using the shell method. [🧊✏️][mw-shells]
- [Support fin](parts/support-fin.scad) - A parametric triangular designed supports holding up objects printed on an edge or corner. [🧊✏️][mw-support-fin]
- [Threads](parts/threads.scad) - A flush threaded container and lid with a recessed, overlapped trapezoidal thread profile. [🧊✏️][mw-parts-threads]
- [Torus](parts/torus.scad) - A reusable torus module based on rotational extrusion, with configurable radii and arc angle. [🧊✏️][mw-torus]

[mw-sample]: https://makerworld.com/en/makerlab/parametricModelMaker?from=model_page&modelName=sample.scad&scadUrl=https%3A%2F%2Fraw.githubusercontent.com%2Fjhermann%2Fthings%2Frefs%2Fheads%2Fmain%2Fmodels%2Fsample.scad
[mw-disks-and-washers]: https://makerworld.com/en/makerlab/parametricModelMaker?from=model_page&modelName=disks-and-washers.scad&scadUrl=https%3A%2F%2Fraw.githubusercontent.com%2Fjhermann%2Fthings%2Frefs%2Fheads%2Fmain%2Fparts%2Fdisks-and-washers.scad
[mw-hull]: https://makerworld.com/en/makerlab/parametricModelMaker?from=model_page&modelName=hull.scad&scadUrl=https%3A%2F%2Fraw.githubusercontent.com%2Fjhermann%2Fthings%2Frefs%2Fheads%2Fmain%2Fparts%2Fhull.scad
[mw-rounded-cubes]: https://makerworld.com/en/makerlab/parametricModelMaker?from=model_page&modelName=rounded-cubes.scad&scadUrl=https%3A%2F%2Fraw.githubusercontent.com%2Fjhermann%2Fthings%2Frefs%2Fheads%2Fmain%2Fparts%2Frounded-cubes.scad
[mw-shells]: https://makerworld.com/en/makerlab/parametricModelMaker?from=model_page&modelName=shells.scad&scadUrl=https%3A%2F%2Fraw.githubusercontent.com%2Fjhermann%2Fthings%2Frefs%2Fheads%2Fmain%2Fparts%2Fshells.scad
[mw-support-fin]: https://makerworld.com/en/makerlab/parametricModelMaker?from=model_page&modelName=support-fin.scad&scadUrl=https%3A%2F%2Fraw.githubusercontent.com%2Fjhermann%2Fthings%2Frefs%2Fheads%2Fmain%2Fparts%2Fsupport-fin.scad
[mw-parts-threads]: https://makerworld.com/en/makerlab/parametricModelMaker?from=model_page&modelName=threads.scad&scadUrl=https%3A%2F%2Fraw.githubusercontent.com%2Fjhermann%2Fthings%2Frefs%2Fheads%2Fmain%2Fparts%2Fthreads.scad
[mw-torus]: https://makerworld.com/en/makerlab/parametricModelMaker?from=model_page&modelName=torus.scad&scadUrl=https%3A%2F%2Fraw.githubusercontent.com%2Fjhermann%2Fthings%2Frefs%2Fheads%2Fmain%2Fparts%2Ftorus.scad


## Articles / Blogs / Tips

- [Bézier curves in OpenSCAD with Inkscape](https://robotix.ah-oui.org/site/main.php?found=260514-tea-pot-code)
- [3D Printing Guides - Troubleshooting & How-Tos](https://www.fixmyprint3d.com/guides) (FixMyPrint)


## Tools & Apps

- [alos-source/openSCADSkill](https://github.com/alos-source/openSCADSkill/tree/master) - An agent for creating 3D models using OpenSCAD
- [etjones/scad2step](https://github.com/etjones/scad2step) - Convert an OpenSCAD file to a STEP file from the command line
- [alpaco.it](https://alpaco.it/) - Parametric 3D print generators, a free web app that turns dimensions you type into printable 3D models (STL/3MF download)
- [stl-er.com](https://www.stl-er.com/) - From Concept to CAD in Seconds (AI 3D Model Generator; commercial; free tier only allows downloads of exiting models, 5 per month)
- [yannickbattail/openscad-generate](https://github.com/yannickbattail/openscad-generate) - `node.js` script to generate 3D models and images from OpenSCAD files.
