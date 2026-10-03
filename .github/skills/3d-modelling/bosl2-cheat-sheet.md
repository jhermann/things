# OpenSCAD BOSL2 Cheat Sheet <!-- omit from toc -->

**Contents**

- [Overview](#overview)
  - [1. Core Concepts \& Overview](#1-core-concepts--overview)
  - [2. Standard Constants (`constants.scad`)](#2-standard-constants-constantsscad)
  - [3. Shorthand Transforms (`transforms.scad`)](#3-shorthand-transforms-transformsscad)
  - [4. Advanced Shapes (`shapes2d.scad` \& `shapes3d.scad`)](#4-advanced-shapes-shapes2dscad--shapes3dscad)
  - [5. Attachments System (`attachments.scad`)](#5-attachments-system-attachmentsscad)
  - [6. Edge and# BOSL2 Library Index \& Context Reference](#6-edge-and-bosl2-library-index--context-reference)
- [1. Import Statements](#1-import-statements)
- [2. Attachability \& Anchor System](#2-attachability--anchor-system)
  - [Standard Anchors](#standard-anchors)
  - [Attaching \& Positioning Operations](#attaching--positioning-operations)
- [3. Difference \& Tagging System (`diff`)](#3-difference--tagging-system-diff)
  - [Core Tagging Functions](#core-tagging-functions)
- [4. 3D Primitive Extensions](#4-3d-primitive-extensions)
  - [Essential 3D Shapes](#essential-3d-shapes)
  - [Edge Specifiers for `edges` Parameter](#edge-specifiers-for-edges-parameter)
- [5. Transforms \& Distribution](#5-transforms--distribution)
  - [Single Transforms](#single-transforms)
  - [Copying \& Arrays (Multi-Transforms)](#copying--arrays-multi-transforms)
- [6. 2D Shapes \& Path Operations](#6-2d-shapes--path-operations)
  - [2D Shapes](#2d-shapes)
  - [Path \& Polygon Tools](#path--polygon-tools)
- [7. Fasteners, Threads \& Joinery](#7-fasteners-threads--joinery)
  - [Hardware (`screws.scad` \& `threading.scad`)](#hardware-screwsscad--threadingscad)
  - [Gears (`gears.scad`)](#gears-gearsscad)
- [8. Math \& Vector Utilities](#8-math--vector-utilities)
- [9. Idiomatic BOSL2 Patterns](#9-idiomatic-bosl2-patterns)
  - [Pattern 1: Hollow Shell with Mounting Bosses](#pattern-1-hollow-shell-with-mounting-bosses)
  - [Pattern 2: Circular Bolt Pattern](#pattern-2-circular-bolt-pattern)

## Overview

### 1. Core Concepts & Overview

The BOSL2 library provides an extensive set of tools that simplify OpenSCAD modeling and make difficult modeling tasks much easier [cite: 1.1.1].

* **Shorthands:** BOSL2 provides concise functions for translations, rotations, and transformations, making code significantly easier to read (e.g., using `up(x)` instead of `translate([0,0,x])`) [cite: 1.1.1].
* **Attachments:** A revolutionary system allowing parts to be positioned and oriented relative to one another (e.g., placing an object on the `TOP` of another) instead of calculating exact coordinates [cite: 1.1.1].
* **Rounding and Filleting:** Simplifies the notoriously difficult task of rounding edges in native OpenSCAD [cite: 1.1.1].
* **VNF (Vertex Normal Faces):** A system for building 3D polyhedrons in separate parts before combining them [cite: 1.2.3].
* **Data Operations:** Supports operations on 2D point lists ("paths" or "regions"), Bezier curves, and complex 3D data like NURBS and Metaballs.

### 2. Standard Constants (`constants.scad`)

BOSL2 uses standardized directional vectors for both attachments and edge/face selection.

* **Directional Vectors:** `LEFT` [-1,0,0], `RIGHT` [1,0,0], `FRONT` [0,-1,0], `BACK` [0,1,0], `BOTTOM` [0,0,-1], `TOP` [0,0,1], `CENTER` [0,0,0] [cite: 1.2.1].
* **General Constants:** `INCH` (25.4), `IDENT` (3D identity transformation matrix) [cite: 1.2.1].
* **Slop:** `$slop` is a constant used to make 3D-printed items fit closely together, defaulting to 0.0 [cite: 1.2.1].
* **Line Specifiers:** Constants like `SEGMENT`, `RAY`, and `LINE` define line boundaries for geometrical operations [cite: 1.2.1].

### 3. Shorthand Transforms (`transforms.scad`)

These operations act on children geometry, 2D paths, or return transformation matrices.

* **Translation:** `move(v)`, `left(x)`, `right(x)`, `fwd(y)`, `back(y)`, `down(z)`, `up(z)` [cite: 1.1.2].
* **Rotation:** `rot(a, [cp=])` extending native rotate. You can also rotate from one direction to another using vectors: `rot(from=[0,0,1], to=[1,0,1])` [cite: 1.1.3]. Axis-specific rotations include `xrot(a)`, `yrot(a)`, and `zrot(a)` [cite: 1.1.2].
* **Scaling & Mirroring:** `scale(v)`, `xscale(x)`, `yscale(y)`, `zscale(z)`. Mirroring and flipping include `mirror(v)`, `xflip()`, `yflip()`, `zflip()` [cite: 1.1.2].

### 4. Advanced Shapes (`shapes2d.scad` & `shapes3d.scad`)

BOSL2 extends native primitives (cubes, cylinders, spheres) into attachable "building blocks" with advanced rounding.

* **2D Attachable Shapes:** `circle()`, `ellipse()`, `squircle()`, `ring()`, `teardrop`, `supershape()`. Paths can be returned instead of geometry [cite: 1.1.2].
* **3D Attachable Shapes:** `cuboid()`, `cylinder()`, `sphere()`, `spheroid()`. Most support arguments like `anchor=`, `spin=`, and `orient=` [cite: 1.1.2].
* Minimum inner radius settings are available on certain circular shapes to guarantee minimal hole sizes for 3D printing [cite: 1.1.1].

### 5. Attachments System (`attachments.scad`)

Attachments allow automatic positioning using directional vectors (anchors) [cite: 1.1.1].

* `position(at)`: Translates children to a designated anchor on the parent object [cite: 1.1.2].
* `orient(anchor, [spin])`: Orients children based on parent anchors [cite: 1.1.2].
* `align(anchor, [align], [inside=])`: Aligns children alongside the parent without making them a physical child part of the parent's attachment tree [cite: 1.1.2].
* `attach(parent_anchor, child_anchor)`: Attaches a child's anchor directly to a parent's anchor.
* Custom objects can be made attachable using `attachable(anchor, spin, orient) { OBJECT; children(); }` [cite: 1.1.2].

### 6. Edge and# BOSL2 Library Index & Context Reference

BOSL2 (Belfry OpenSCAD Library v2) replaces OpenSCAD's basic primitives with attachable shapes, precise edge rounding/chamfering, boolean tagging systems, advanced transformations, and path/geometry tools.

## 1. Import Statements

```openscad
// Standard import (covers ~90% of core features, shapes, transforms, attachability)
include <BOSL2/std.scad>

// Optional specialized libraries (include as needed)
include <BOSL2/screws.scad>      // Bolts, nuts, screw holes, countersinks
include <BOSL2/threading.scad>   // Threaded rods, custom threads, trapezoidal threads
include <BOSL2/gears.scad>       // Spur, helical, bevel, rack, and ring gears
include <BOSL2/joiners.scad>     // Dovetails, snap pins, hinges, clip joints
include <BOSL2/beziers.scad>     // Bézier curves and surface patches
include <BOSL2/rounding.scad>    // 2D/3D masking, fillets, complex bevels
```

## 2. Attachability & Anchor System

BOSL2 shapes have built-in anchor points and orientation vectors. Children attach to parent anchors without manual offset calculations.

### Standard Anchors

* **Directional Vectors:** `CENTER` (`CTR`), `TOP` (`T`), `BOTTOM` (`B`), `LEFT` (`L`), `RIGHT` (`R`), `FRONT` (`F`), `BACK` (`BK`)
* **Combined Vectors:** Add vectors together (e.g., `TOP+RIGHT` / `TR`, `BOTTOM+FRONT+LEFT` / `BFL`)
* **Vector Definitions:**
* `RIGHT` = `[1, 0, 0]`, `LEFT` = `[-1, 0, 0]`
* `BACK` = `[0, 1, 0]`, `FRONT` = `[0, -1, 0]`
* `TOP` = `[0, 0, 1]`, `BOTTOM` = `[0, 0, -1]`



### Attaching & Positioning Operations

| Module | Syntax | Description |
| --- | --- | --- |
| `attach()` | `attach(anchor, [from_anchor], [spin])` | Attaches child's `from_anchor` (default `BOTTOM`) to parent's `anchor` and aligns vectors. |
| `position()` | `position(anchor)` | Moves child's origin to parent's `anchor` without rotating orientation. |
| `orient()` | `orient(dir)` | Rotates object so its `TOP` vector points along `dir`. |
| `align()` | `align(anchor)` | Moves object inside a space so its bounding box aligns to `anchor`. |
| `show_anchors()` | `show_anchors([s])` | Visualizes anchor positions and orientation arrows on a shape. |

```openscad
// Attach a cylinder to the top-right corner of a cuboid
cuboid([50, 40, 30]) {
    attach(TOP+RIGHT, BOTTOM) cyl(h=15, d=10);
}
```

## 3. Difference & Tagging System (`diff`)

Replaces nested standard CSG boolean operations with tag-based subtraction and intersection.

### Core Tagging Functions

| Module | Description |
| --- | --- |
| `diff(to_remove, [keep])` | Subtracts children tagged with `to_remove` from main geometry. |
| `tag(name)` | Applies a string tag to child elements. |
| `tag_diff()` / `tag_conv()` | Pre-tagged sub-operations for complex CSG trees. |
| `hide(name)` / `show(name)` | Excludes or isolates tagged elements during render. |
| `intersect(tag)` | Intersects tagged elements with parent shape. |

```openscad
// Create a box with a hole cut through it using tags
diff("hole")
cuboid([40, 40, 20]) {
    tag("hole") attach(CENTER) cyl(h=25, d=12);
}
```

## 4. 3D Primitive Extensions

All primitives support `anchor`, `spin`, `orient`, and edge control parameters (`rounding`, `chamfer`).

### Essential 3D Shapes

```openscad
// Cuboid with selective edge rounding or chamfering
cuboid([x, y, z], [center=bool], [rounding=r], [chamfer=c], [edges=edge_spec]);

// Cylinder / Cone
cyl(h=z, r|d=val, [r1|d1=val], [r2|d2=val], [rounding=r], [chamfer=c]);

// Spheroid / Sphere
spheroid(r|d=val, [r2=val], [style="icosphere"|"octa"]);

// Truncated Pyramid / Prismoid
prismoid(size1=[x1,y1], size2=[x2,y2], h=z, [shift=[x,y]]);

// Tube / Pipe
tube(h=z, od|or=val, id|ir=val, [wall=w]);

// Teardrop (3D print friendly horizontal hole profile)
teardrop(h=z, r|d=val, [angle=45]);

// Torus
torus(r_maj=R, r_min=r);
```

### Edge Specifiers for `edges` Parameter

* `EDGES_ALL`, `EDGES_NONE`
* `EDGES_Z_ALL` (4 vertical edges)
* `EDGES_X_ALL`, `EDGES_Y_ALL`
* `EDGES_TOP`, `EDGES_BOTTOM`
* `EDGES_LEFT`, `EDGES_RIGHT`, `EDGES_FRONT`, `EDGES_BACK`
* Expressive combinations: `EXCEPT_TOP`, `TOP+EDGES_LEFT`, `EDGES_Z_ALL - FRONT`

## 5. Transforms & Distribution

Transforms in BOSL2 chain cleanly and replace basic OpenSCAD movement.

### Single Transforms

| Module | Equivalent | Description |
| --- | --- | --- |
| `move([x,y,z])` | `translate()` | Moves along axes. |
| `xmove(x)`, `ymove(y)`, `zmove(z)` | — | Move along a single axis. |
| `up(z)`, `down(z)`, `left(x)`, `right(x)`, `fwd(y)`, `back(y)` | — | Directional movement aliases. |
| `rot([x,y,z])` | `rotate()` | Rotation around origin. |
| `xrot(deg)`, `yrot(deg)`, `zrot(deg)` | — | Single-axis rotation. |
| `xflip()`, `yflip()`, `zflip()` | `mirror()` | Flips across specified axis plane. |

### Copying & Arrays (Multi-Transforms)

```openscad
// Linear copies
xcopies(spacing, n=count) children();
ycopies(spacing, n=count) children();
zcopies(spacing, n=count) children();

// Grid array
grid_copies(spacing=[x,y], n=[cols, rows]) children();

// Rotational copies around Z-axis
zrot_copies(n=count, [r=radius], [subrot=true|false]) children();

// Arc distribution
arc_copies(n=count, r=radius, sa=start_angle, ea=end_angle) children();

// Reflection copies (creates original + mirrored version)
mirrored(v=[1,0,0]) children();
```

## 6. 2D Shapes & Path Operations

BOSL2 expands 2D geometry and vector path manipulation.

### 2D Shapes

* `rect([x,y], [rounding=r], [chamfer=c])`
* `circle(r|d=val)` / `ellipse(r|d=[rx,ry])`
* `star(n=points, r1=outer, r2=inner)`
* `regular_ngon(n=sides, r|d=val)`
* `trapezoid(h=y, w1=bottom_x, w2=top_x)`

### Path & Polygon Tools

| Function / Module | Description |
| --- | --- |
| `stroke(path, width=w, [closed=bool])` | Converts a 2D path vector into a 3D or 2D renderable line/polygon. |
| `offset(path, r | delta=val, [chamfer=bool])` |
| `sweep(path, profile)` | Extrudes a 2D profile along a 3D path trajectory. |
| `path_round_corners(path, r)` | Rounds sharp turns in a point vector array. |
| `subdivide_path(path, n)` | Increases point density along a path. |

## 7. Fasteners, Threads & Joinery

### Hardware (`screws.scad` & `threading.scad`)

```openscad
// Metric Bolt
metric_bolt(size="M3", l=12, head="hex"|"pan"|"countersunk", [length=12]);

// Screw Clearance Hole with Countersink/Counterbore
screw_hole(spec="M3x12", [head="pan"|"countersunk"], [counterbore=depth]);

// Threaded Rod
threaded_rod(d=10, l=30, pitch=1.5, [thread_angle=60]);

// Metric Nut
threaded_nut(nut_type="M3", [od=val], [h=val]);
```

### Gears (`gears.scad`)

```openscad
// Spur Gear
spur_gear(circ_pitch=p | mod=m, teeth=N, thickness=h, [shaft_diam=d]);

// Rack Gear
rack(circ_pitch=p | mod=m, teeth=N, thickness=h, height=base_h);

// Helical / Bevel Gears
helical_gear(mod=m, teeth=N, helix_angle=deg, thickness=h);
bevel_gear(mod=m, teeth=N, cone_angle=deg, thickness=h);
```

## 8. Math & Vector Utilities

Functions used within OpenSCAD expression evaluations.

| Category | Functions |
| --- | --- |
| **Vector Operations** | `unit(v)` (normalize), `norm(v)` (magnitude), `quant(val, step)` (snap to grid) |
| **List Manipulations** | `select(list, start, end)`, `reverse(list)`, `flatten(list)`, `sum(list)` |
| **Interpolation** | `lerp(a, b, t)`, `smoothstep(t)`, `bezier_curve(p_list, t)` |
| **Matrix Transforms** | `rot(v)` matrix generation, `apply(transform_matrix, points)` |

## 9. Idiomatic BOSL2 Patterns

### Pattern 1: Hollow Shell with Mounting Bosses

```openscad
include <BOSL2/std.scad>

diff("cutouts")
cuboid([60, 40, 30], rounding=3, teardrop=true) {
    // Hollow out inside
    tag("cutouts") position(TOP) down(2)
        cuboid([54, 34, 28], rounding=2);

    // Add internal bosses using position
    position(BOTTOM+LEFT+FRONT) move([8, 8, 2])
        cyl(h=26, d=8, anchor=BOTTOM) {
            tag("cutouts") attach(TOP) cyl(h=26, d=3);
        }
}
```

### Pattern 2: Circular Bolt Pattern

```openscad
include <BOSL2/std.scad>
include <BOSL2/screws.scad>

diff("screws")
cyl(h=10, d=80) {
    tag("screws")
    attach(TOP)
    zrot_copies(n=6, r=30) {
        screw_hole("M4x10", head="countersunk");
    }
}```
