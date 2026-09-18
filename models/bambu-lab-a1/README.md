# BambuLab A1 Traversal Mount

A parametric model for mounting something on the traversal connecting the A1 Z screws.

> ![Model Preview](./preview.png)

> ![Printed Mounting Bracker](./bracket-printed.jpg)
>
> *Printed Mounting Bracket*

## 3D Files

- [upper-traversal-mount.scad](./upper-traversal-mount.scad) - Parametric OpenSCAD source.
- [upper-traversal-mount.3mf](./upper-traversal-mount.3mf) - Ready-to-slice model.

## Plate 2: Tapo C230 Camera Mount

The second plate combines the A1 traversal bracket with a twist-lock holder
for the [TP-Link Tapo C230 camera](../camera-tapo-230/README.md). It uses the
same camera interface as the standalone wall mount, but replaces the wall
plate with a mount for the A1 traversal.

The holder dimensions and the bracket dimensions are parameters in
[upper-traversal-mount.scad](./upper-traversal-mount.scad), so the model can
be adjusted for fit before slicing.
