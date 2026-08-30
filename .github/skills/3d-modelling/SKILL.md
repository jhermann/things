---
name: 3d-modelling
description: OpenSCAD script generation utilizing the BOSL2 standard library for parametric 3D printing and mechanical design.
version: 1.0.0
---

## Target Domain

OpenSCAD script creation optimized for BOSL2 (Boston OpenSCAD Library v2).

This skill can be explicitly triggered by using the `/scad` command with a prompt, and applies to all files with the `.scad` extension.

## Core Directives

- **Library Inclusion:** Always begin scripts by importing the standard BOSL2 environment via `include <BOSL2/std.scad>`. Never mix legacy BOSL v1 syntax with BOSL2.
- **Parametric Design:** Define all core dimensions, tolerances, and configuration parameters as variables at the top of the file.
- **Leverage BOSL2 Primitives:** Replace native OpenSCAD primitives with BOSL2 equivalents (`cuboid`, `cyl`, `sphere`) which natively support arguments like `rounding`, `chamfer`, `or`, and `anchor`.
- **Attachment System:** Use BOSL2's attachment and positioning functions (`position()`, `orient()`, `edge_profile()`) instead of manual translation/rotation arithmetic for complex sub-assembly alignments.
- **Printability & Tolerances:** Explicitly factor in 3D printing clearance variables (e.g., `$fn = 64;` for smooth cylinders, `clearance = 0.2;` for mating parts).
- **Layer Height & Resolution:** Use `$fa` and `$fs` to control facet angle and size for high-quality prints, adjusting based on the complexity of the geometry. Features like chamfers should not be smaller than the standard layer height of 0.2mm.
- **Consistent Dimensions:** Maintain consistent units (millimeters) and avoid mixing metric and imperial measurements. Use clear variable names to indicate the purpose of each dimension (e.g., `wall_thickness`, `hole_diameter`).
- **Reduce Redundancy:** Use the same variable for the same dimension across different modules to ensure consistency, and if necessary use multiples to reduce configuration complexity for similar dimensions, like `ribbing_size = wall_thickness / 2`.


## Code Structure

- **Basic Template:** The [template.scad](./template.scad) file provides a starting point for new designs, demonstrating the recommended structure and BOSL2 usage patterns.
- **Module Organization:** Group related geometric features into separate modules, and use descriptive names for clarity.
- **Parameterization:** All key dimensions and tolerances should be defined as top-level variables, allowing for easy adjustments without modifying the core logic.
- **Preview Mode:** Use the `$preview` variable to toggle between high-fidelity and low-fidelity rendering for faster iteration during development.
- **Derived Calculations:** Keep derived calculations below the `/* [Hidden] */` marker to avoid cluttering the main parameter section.
- **File Organization:** Keep the file organized with clear sections for settings, modules, and main execution code.
- **Examples:** Include example usage snippets to demonstrate how to instantiate and combine modules effectively.
- **Naming Conventions:** Use clear and consistent naming for modules, variables, and files to improve readability and maintainability.
- **Commenting:** Include concise inline comments explaining non-obvious geometric transformations or design constraints. Comments should also be used to capture the rationale behind design decisions, especially when deviating from standard practices.

## Quality Standards & Guardrails

- **Modularization:** Break complex designs down into distinct, reusable OpenSCAD modules.
- **Performance:** Structure CSG operations (`difference`, `union`, `intersection`) efficiently to minimize rendering overhead.
- **Documentation:** Include concise inline comments explaining non-obvious geometric transformations or design constraints.
