// Bent Tube
//
// Hollow round tube swept along a polyline path with BOSL2's path_sweep();
// it runs straight up and then bends sideways.

include <BOSL2/std.scad>

// TODO: Use bend_angle instead of bend_rise

/* [Main Settings] */
// Outer radius of the tube
outer_radius = 15; // [2:0.5:50]
// Wall thickness of the tube
wall_thickness = 1.5; // [0.4:0.1:5]
// Height of the straight section
straight_length = 5; // [1:1:100]
// Horizontal offset of the bend
bend_offset = 10; // [1:1:100]
// Vertical rise of the bend
bend_rise = 10; // [1:1:100]

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
    offset_r = bend_offset + outer_radius;
    radius_b = max(outer_radius, bend_rise);
    length_s = straight_length + outer_radius;
    height = straight_length + outer_radius + bend_rise;
    tube_path = round_corners(
        [
            [0, 0, -eps],
            [0, 0, length_s],
            [offset_r + eps, 0, height + eps],
        ],
        method = "circle", radius = radius_b,
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

module deconstruct(what_part="back") {
    color("crimson")
    intersection() {
        mw_plate_1();

        up(outer_radius) back(epsilon)
        zrot(what_part == "back" ? 0 : 90)
        cuboid([6 * outer_radius, tolerance, 6 * outer_radius], center=true);
    }

    color("ivory")
    if (what_part == "back") back_half() mw_plate_1();
    else right_half() mw_plate_1();

}

module mw_plate_1() {
    bent_tube();
}

if ($preview) {
    deconstruct("back");

    left(2.5 * outer_radius) zrot(90)
    deconstruct("right");

    color("crimson") tube_shape(tolerance / 2);
} else {
    mw_plate_1();
}
