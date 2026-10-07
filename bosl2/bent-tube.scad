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
$fa = $preview ? 8 : 2;
$fs = $preview ? 1 : 0.4;

tolerance = 0.25;
epsilon = 0.05;

// Keep derived calculations below this line,
// so they are hidden from the user interface

inner_radius = outer_radius - wall_thickness;

// ====================================================================
// Parts
// ====================================================================

module tube_shape(radius, eps=0) {
    tube_path = round_corners(
        [
            [0, 0, -eps],
            [0, 0, straight_length],
            [bend_offset + eps, 0, straight_length + bend_rise + eps],
        ],
        method = "circle", radius = max(radius, 0.25 * bend_rise),
        closed = false,
    );

    path_sweep(
        circle(radius),
        path = tube_path,
        uniform = false,
        relaxed = true,
    );
}

module bent_tube() {
    difference() {
        tube_shape(outer_radius);
        tube_shape(inner_radius, epsilon);
    }
}

// ====================================================================
// Plates
// ====================================================================

module mw_plate_1() {
    bent_tube();
}

if ($preview) {
    back_half() mw_plate_1();
    up(straight_length + + bend_offset + bend_rise) zrot(90)
    right_half()mw_plate_1();

    tube_shape(tolerance / 2);
} else {
    mw_plate_1();
}
