// Two hinged bars that close via a snap-fit mechanism
// (simple bag clip)

include <BOSL2/std.scad>

/* [Bars] */
// Length of each bar
bar_length = 60; // [30:1:150]
// Width of each bar
bar_width = 12; // [8:0.5:30]
// Height (thickness) of the bars
bar_height = 9; // [6:0.5:30]
// Gap between the closed bars, sized for the clamped material
clamp_gap = 0.5; // [0.25:0.25:5]
// Hinge opening angle, 0 is the closed and snapped state
open_angle = 0; // [0:1:120]
// Chamfer on the top and bottom edges
chamfer = 0.8; // [0:0.1:2]

/* [Hinge] */
// Diameter of the hinge pin
pin_diameter = 5; // [3:0.5:10]

/* [Snap Fit] */
// Thickness of the flexing finger
finger_thickness = 2; // [1:0.1:4]
// How far the barb reaches under the fixed bar
barb_depth = 1.2; // [0.5:0.1:3]
// Height of the barb's ramp
barb_height = 2.5; // [1:0.1:6]

/* [Hidden] */
$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.2;

// Clearance between moving parts
tolerance = 0.25;
// Overlap to fuse coplanar faces
epsilon = 0.01;

half_gap = clamp_gap / 2;
knuckle_radius = bar_width / 2;
layer = (bar_height - 2 * tolerance) / 3;

// The barb catches the underside of the fixed bar
barb_top_y = -(bar_width + half_gap) - tolerance;
finger_x = bar_length + tolerance;


module see_through(base_color="grey", alpha=0.6) {
    if ($preview) {
        color(base_color, alpha)
            children();
    } else {
        children();
    }
}

module chamfered_extrude(region, h, bottom=true, top=true) {
    if (chamfer > 0)
        offset_sweep(region, height=h,
            bottom=bottom ? os_chamfer(width=chamfer) : undef,
            top=top ? os_chamfer(width=chamfer) : undef);
    else
        linear_extrude(h)
            region(region);
}

module solid(base_color="red") {
    if ($preview) {
        color(base_color)
            children();
    } else {
        children();
    }
}


// ====================================================================
// Fixed bar: pin, two outer knuckles and the catch edge
// ====================================================================

function fixed_bar_profile() =
    move([0, -(bar_width + half_gap)],
        p=rect([bar_length, bar_width], anchor=[-1, -1]));

module fixed_bar() {
    // Full-height bar, clear of the moving knuckle
    chamfered_extrude(
        difference(fixed_bar_profile(), circle(r=knuckle_radius + tolerance)),
        bar_height);

    // Outer knuckles sandwiching the moving one
    knuckle = union(fixed_bar_profile(), circle(r=knuckle_radius));
    chamfered_extrude(knuckle, layer, top=false);
    translate([0, 0, bar_height - layer])
        chamfered_extrude(knuckle, layer, bottom=false);

    cyl(d=pin_diameter, h=bar_height, anchor=BOTTOM);
}


// ====================================================================
// Moving bar: middle knuckle and a flexing finger with a barb
// ====================================================================

function moving_bar_profile() =
    union([
        move([0, half_gap],
            p=rect([finger_x + finger_thickness, bar_width], anchor=[-1, -1])),

        // Finger reaching down past the fixed bar's end
        move([finger_x, barb_top_y - barb_height],
            p=rect([finger_thickness, bar_width + half_gap - barb_top_y + barb_height], anchor=[-1, -1])),

        // Barb with a ramp on the leading edge
        [
            [finger_x + epsilon, barb_top_y],
            [finger_x - barb_depth, barb_top_y],
            [finger_x + epsilon, barb_top_y - barb_height],
        ],
    ]);

module moving_bar() {
    chamfered_extrude(
        difference(moving_bar_profile(), circle(r=knuckle_radius + tolerance)),
        bar_height);

    // Middle knuckle, spinning on the pin
    translate([0, 0, layer + tolerance])
        linear_extrude(layer)
            difference() {
                union() {
                    circle(r=knuckle_radius);
                    translate([0, half_gap])
                        square([knuckle_radius + tolerance + 1, bar_width]);
                }
                circle(r=pin_diameter / 2 + tolerance);
            }
}


// ====================================================================
// Assembly
// ====================================================================

solid("red")
    zrot(open_angle)
        moving_bar();

see_through("lime", alpha=.4)
    fixed_bar();
