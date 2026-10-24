// Connectagon
//
// A hollow, extruded hexagon with 5 mm walls that snaps together with its
// neighbours. Every wall carries three vertical cylinders: on alternating
// walls they are grooves cut 3/4 of their diameter into the wall, on the
// other walls they are solid ribs protruding 3/4 of their diameter. Opposite
// walls are of opposite type, so identical tiles interlock in a honeycomb.

include <BOSL2/std.scad>

/* [Main Settings] */
// Outer width of the hexagon across opposite walls
hex_width = 60; // [30:1:150]
// Height of the extrusion
height = 30; // [4:1:50]
// Wall thickness
wall_thickness = 3; // [3:0.5:10]

/* [Connectors] */
// Diameter of the connector cylinders
cyl_diameter = 2.5; // [2:0.5:8]
// Distance between the three cylinders along a wall
cyl_spacing = 8; // [5:0.5:15]
// Share of the cylinder diameter that sits on the far side of the wall surface
cyl_depth_ratio = 0.75; // [0.25:0.05:1]
// Extra diameter of the grooves, for a loose fit of the ribs
tolerance = 0.2; // [0:0.05:0.5]

/* [Hidden] */
//$preview = true;
local = 1;
$fa = $preview ? 16 : 2;
$fs = $preview ? 1 : 0.2;

// Extra size added to carve-out shapes
epsilon = 0.05;

// Keep derived calculations below this line,
// so they are hidden from the user interface

// Inner radius (center to wall surface) of the outer and inner hexagon
outer_ir = hex_width / 2;
inner_ir = outer_ir - wall_thickness;
// Offset of the cylinder axis from the wall surface
cyl_offset = cyl_diameter * (cyl_depth_ratio - 0.5);
groove_radius = (cyl_diameter + tolerance) / 2;
groove_edge_y = sqrt(max(0, groove_radius * groove_radius - cyl_offset * cyl_offset));

echo("SIZE H × W:", height, hex_width);

// ====================================================================
// Helpers
// ====================================================================

module solid(base_color="red") {
    if ($preview) {
        color(base_color)
            children();
    } else {
        children();
    }
}


// ====================================================================
// Parts
// ====================================================================

// Hexagonal ring; its walls face 30°, 90°, 150°, ...
module hex_body() {
    edge_chamfer = cyl_diameter * (1 - cyl_depth_ratio) - tolerance - epsilon;

    difference() {
        regular_prism(6, h=height, ir=outer_ir, chamfer=edge_chamfer, anchor=BOTTOM);
        down(epsilon)
            regular_prism(6, h=height + 2 * epsilon, ir=inner_ir, chamfer=-edge_chamfer, anchor=BOTTOM);
    }
}

// Places children three times along the wall that faces the given angle,
// with the origin at the wall surface
module on_wall(angle) {
    zrot(angle)
        right(outer_ir)
            ycopies(spacing=cyl_spacing, n=3)
                children();
}

// Solid ribs, sunk into the wall by (1 - cyl_depth_ratio) of their diameter
module ribs(angle) {
    on_wall(angle)
        right(cyl_offset)
            cyl(d=cyl_diameter, h=height, chamfer=tolerance, anchor=BOTTOM);
}

// Grooves, cut cyl_depth_ratio of their diameter into the wall
module grooves(angle) {
    on_wall(angle)
        union() {
            left(cyl_offset)
                down(epsilon)
                    cyl(d=cyl_diameter + tolerance, h=height + 2 * epsilon, chamfer=-tolerance, anchor=BOTTOM);
            if (tolerance > 0)
                for (side = [-1, 1])
                    back(side * groove_edge_y)
                        down(epsilon)
                            cyl(d=tolerance, h=height + 2 * epsilon, anchor=BOTTOM);
        }
}


// ====================================================================
// Main Assembly & Plates
// ====================================================================

module connectagon() {
    difference() {
        union() {
            hex_body();
            // Walls at 30°, 150°, 270° get ribs
            solid("steelblue")
                for (a = [30, 150, 270]) ribs(a);
        }
        // Opposite walls at 90°, 210°, 330° get grooves
        for (a = [90, 210, 330]) grooves(a);
    }
}


// ====================================================================
// Plates
// ====================================================================
module assembly() {
    connectagon();
}

module mw_plate_1() {
    connectagon();
}

if ($preview || local) { // main assembly in Parametric Model Maker
    if ($preview) assembly();
    else mw_plate_1();
}
