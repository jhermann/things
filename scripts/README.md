# SCAD File Previews

`preview.sh` renders the top-level `.scad` files in the repository's reusable-part and example directories, then creates a tiled [preview.png](../parts/preview.png) in each directory:

- [`parts/`](../parts/preview.png)
- [`parts/textures/`](../parts/textures/preview.png)
- [`examples/`](../examples/preview.png)

Captions use the source filename with hyphens replaced by spaces and words capitalized. Model directories are not included because their previews are maintained with the individual models.

The script is configured for OpenSCAD Nightly installed on Windows and run from WSL. It also requires `wslpath` and ImageMagick's `montage` command.

From the repository root or any other directory, run:

```bash
./scripts/preview.sh
```

Adjust the render size, tile count, colorscheme, colors, or output filename in the configuration section at the top of `preview.sh`.
