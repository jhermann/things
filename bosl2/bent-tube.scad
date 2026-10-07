// Bent Tube
//
// Hollow round tube swept along a polyline path with BOSL2's path_sweep();
// it runs straight up and then bends sideways.

include <BOSL2/std.scad>

/* [Main Settings] */
// Outer radius of the tube
outer_radius = 15; // [2:0.5:50]
// Wall thickness of the tube
wall_thickness = 1.5; // [0.4:0.1:5]
// Height of the straight section
straight_length = 15; // [1:1:100]
// Horizontal offset of the bend
bend_offset = 15; // [1:1:100]
// Vertical rise of the bend
bend_rise = 15; // [1:1:100]

/* [Hidden] */
//$preview = true;
local = 0;
$fa = $preview ? 8 : 2;
$fs = $preview ? 1 : 0.4;

// Keep derived calculations below this line,
// so they are hidden from the user interface

inner_radius = outer_radius - wall_thickness;
bend_joint = min(straight_length, norm([bend_offset, bend_rise])) / 2;
tube_path = round_corners(
    [
        [0, 0, 0],
        [0, 0, straight_length],
        [bend_offset, 0, straight_length + bend_rise],
    ],
    method = "smooth",
    joint = bend_joint,
    closed = false
);

// ====================================================================
// Parts
// ====================================================================

module bent_tube() {
    path_sweep(
        shape = difference([
            circle(outer_radius),
            circle(inner_radius),
        ]),
        path = tube_path,
        uniform = false
    );
}

// ====================================================================
// Plates
// ====================================================================

module mw_plate_1() {
    bent_tube();
}

if ($preview || local) { // main assembly in Parametric Model Maker
    mw_plate_1();
}
