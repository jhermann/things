# MakerWorld Multi-Plate Example

## Introduction

MakerWorld identifies multiple build plates statically before running the code by scanning for specific module names formatted as `mw_plate_X()`.

Below is the exact structural template required for a MakerWorld multi-plate `.scad` file, followed by a fully functional example and an active model page utilizing this system.

## The MakerWorld Multi-Plate .scad Template

To make your parametric design automatically split across separate plates in the MakerWorld customizer interface, use the specific layout in [mw-multi-part.scad](./mw-multi-part.scad).

## Key Requirements for MakerWorld Validation

1. **Plate 1 Cannot Be Empty:** The Parametric Model Maker utilizes `mw_plate_1()` to generate the default cover thumbnail image. If `mw_plate_1()` is empty or contains unrendered logic, the upload will fail validation.

2. **Static Module Declaration:** The multi-plate framework is parsed before runtime. You cannot dynamically generate plates using loops or conditional arrays (e.g., you cannot use `module mw_plate_part(index)`). They must be written explicitly out as `mw_plate_1()`, `mw_plate_2()`, `mw_plate_3()`, etc.

3. **Orientation Matters:** While your main_assembly() module should display the objects aligned as a finished product, the individual `mw_plate_X()` modules must rotate and position the pieces flat on the Z=0 plane exactly how they should be printed.

## Active Live Examples on MakerWorld

If you want to download and inspect a highly successful, fully featured project built natively with this multi-plate `.scad` standard, look at the [Deskware - A Modular Desk System](https://makerworld.com/en/models/1331760-deskware-a-modular-desk-system) model on MakerWorld. Clicking "Customize" on its page allows you to see how plate 0 functions as the global assembly view, while plates 1 and onward break the rails and components into individual print layouts.


**References**

- [Unofficial MakerWorld PMM OpenSCAD Reference](https://mindflakes.com/posts/2026/05/04/makerworld-pmm-openscad-reference/)
- [How to upload parametric models on MakerWorld?](https://www.reddit.com/r/BambuLab/comments/1f730f2/how_to_upload_parametric_models_on_makerworld/)
- [SCAD cut object and move to multiple build plates](https://forum.bambulab.com/t/scad-cut-object-and-move-to-multiple-build-plates/153064)
- [Parametric Model Maker V0.10.0 - Multi-Plate 3MF Generation](https://forum.bambulab.com/t/parametric-model-maker-v0-10-0-multi-plate-3mf-generation/144618?page=2)
- [FYI - Multiplate .scad validation fails if mw_plate_1() is empty](https://forum.bambulab.com/t/fyi-multiplate-scad-validation-fails-if-mw-plate-1-is-empty/231502)
- [Deskware - A Modular Desk System](https://makerworld.com/en/models/1331760-deskware-a-modular-desk-system)
