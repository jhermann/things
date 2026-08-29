# Textures

Reusable OpenSCAD texture patterns and sample plates or containers that demonstrate them.

## Texture Examples

> ![Tiled Preview](./preview.png)

- [Diamond tread](diamond-tread.scad) - A raised diamond pattern on a flat plate.
- [Japandi](japandi.scad) - An organic, vertically rippled cylinder.
- [Knurling](knurling.scad) - A repeating knurled surface pattern.
- [Ribbing](ribbing.scad) - A repeating ribbed surface pattern.
- [Stippling](stippling.scad) - A surface pattern made from small raised points.

## Preview

`preview.sh` renders every `.scad` file in this directory and combines the results into a three-column tiled image at [preview.png](preview.png). Captions use the source filename with hyphens replaced by spaces and words capitalized.

The script is configured for OpenSCAD Nightly installed on Windows and run from WSL. It also requires `wslpath` and ImageMagick's `montage` command.

From this directory, run:

```bash
./preview.sh
```

Adjust the render size, tile count, colorscheme, colors, or output filename in the configuration section at the top of `preview.sh`.
