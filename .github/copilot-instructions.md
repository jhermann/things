# Copilot Instructions

## Repository Workflow

- This repository contains parametric, millimetre-based OpenSCAD designs for 3D printing. There is no package manager, build system, test suite, or linter.
- Validate one changed design by rendering it with OpenSCAD; write the generated STL outside the repository:

  ```bash
  mkdir -p /tmp/things-validate
  openscad --render -o /tmp/things-validate/model.stl path/to/model.scad
  ```

  For example:

  ```bash
  openscad --render -o /tmp/things-validate/ac-drain-pan.stl models/ac-drain-pan/ac-drain-pan.scad
  ```

- Regenerate tiled PNG previews for reusable parts and examples with:

  ```bash
  ./scripts/preview.sh
  ```

  The script renders only top-level `.scad` files in `bosl2/`, `examples/`, `parts/`, `parts/joining/`, and `parts/textures/`. It requires `openscad` and ImageMagick's `montage`; its configuration documents the Windows/WSL Nightly OpenSCAD setup. Do not use it for model-directory previews, which are maintained per model.

## Architecture

- `models/` contains standalone, printable projects. Each named model directory owns its SCAD source, README, and any model-specific assets; `models/README.md` and the root README are their discovery indexes. Keep a model's assembly at the end of its SCAD file after its feature modules.
- `parts/` is a reusable-pattern and experimental geometry library, divided into general parts, `joining/`, and `textures/`. Its top-level SCAD files are also rendered as examples in the tiled previews, so each must produce a useful default scene.
- `bosl2/` contains BOSL2 examples, not a vendored library. New BOSL2-based designs depend on an OpenSCAD-installed `BOSL2` library through `include <BOSL2/std.scad>`.
- `examples/mw-multi-part.scad` is the repository template for MakerWorld multi-plate designs. Larger MakerWorld-targeted models additionally expose a normal assembled preview while defining printable plate modules. The plate modules should be minimal and only reference the assembly's feature modules; they are not intended to be a full copy of the assembly. The zero plane is the print plate, objects must be positioned exactly how they should be printed, usually flat on the Z=0 plane. The assembly preview is for visualizing the model, not for printing.

## OpenSCAD Conventions

- Follow the repository's 3D-modelling skill for new or substantially revised SCAD: begin BOSL2 designs with `include <BOSL2/std.scad>`, put user-facing parameters first in `/* [Section] */` blocks, and place derived values under `/* [Hidden] */`. The annotations are consumed by MakerWorld's Parametric Model Maker.
- Define core dimensions, wall thicknesses, tolerances, and quality settings as top-level parameters. Keep units in millimetres and derive related dimensions once rather than duplicating numeric literals across modules.
- Use `$preview` to make interactive previews coarse and final renders smooth. Existing reusable parts conventionally use `$fa`/`$fs` conditionals; models that need fixed quality expose `$fn` as a parameter. Preserve the local file's established resolution style when editing it.
- Decompose geometry into feature modules and compose the final shape with explicit CSG operations. Use small `edge_pad`/overcut values when a subtractive solid must fully cross its target; this is the established way to avoid coplanar CSG artifacts.
- For new complex designs, prefer BOSL2 primitives and its attachment system over manual coordinate arithmetic. Preserve native OpenSCAD style in existing legacy models unless the task calls for a broader migration.
- MakerWorld multi-plate files must declare each `mw_plate_N()` module explicitly; they cannot be generated dynamically. `mw_plate_1()` must be non-empty, and every plate module must place its part flat on the Z=0 print plane. Keep the normal root/assembly view separate from those print-oriented plates.

## Formatting and Documentation

- `.editorconfig` sets four-space indentation for SCAD and Markdown; retain a file's existing indentation when touching legacy content that predates this rule.
- Update the nearest README and the root or `models/README.md` index when adding a user-facing model, reusable part, or preview that changes the documented collection.
- Keep indexes flat, do not nest README links in subdirectories. Use the model's directory name as the link text, and do not include the `.scad` extension.
- Ensure sub-level READMEs are self-contained and do not require the reader to navigate to parent directories for context. Each README should describe the model or part, its intended use, and any relevant parameters or assembly instructions.
- A README should not be a copy of the root README or a generic OpenSCAD tutorial, and make any sub-level READMEs discoverable from the parent README. Use the root README to describe the repository as a whole, not individual models or parts.

## Technical Details

- OpenSCAD libraries are installed in `~/.local/share/OpenSCAD/libraries/`.
- NEVER call `find / ...` to find things; ask the user for things you are missing.
