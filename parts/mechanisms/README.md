# Mechanisms

Reusable OpenSCAD mechanisms for moving or connecting printed parts.

> ![Tiled Preview](./preview.png)

## Vertical Conical Hinge

[OpenSCAD source](./hinge.scad)

A parametric print-in-place hinge with conical interlocking surfaces. The source
includes a sample assembly to preview the hinge and its mating body.

Adjust `outer_diameter`, `inner_diameter`, and `height` to change the hinge
geometry; `size` controls the surrounding sample body. The fit clearance is
defined by the hidden `tolerance` value. Open the file in OpenSCAD to customize
the parameters and render the assembly.

> ![Hinge preview](./assets/hinge-preview.png)
>
> ![Sliced hinge](./assets/hinge-sliced.png)
>
> ![Printed hinge](./assets/hinge-printed.jpg)
