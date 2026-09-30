// A bulky curve formed like an omega connected to opposite handles that can flex

include <BOSL2/std.scad>

/* [Spring Dimensions] */
// Outer diameter of the loop
loop_diameter = 30; // [10:1:80]
// Scale of the loop along the Y axis (1 = circle)
loop_squash = 0.7; // [0.3:0.05:1]
// Angle below the horizontal where the loop ends and the legs begin
loop_end_angle = 30; // [0:5:60]
// Length of the straight legs leaving the loop
leg_length = 3; // [2:0.5:30]
// Length of the straight handle leaving the end of each coil, along the X axis
handle_length = 8; // [3:1:30]
// Band width in the plane of the spring
band_width = 3; // [0.4:0.1:6]
// Spring height (extrusion)
spring_height = 10; // [1:0.5:30]
// Chamfer on the top and bottom edges
chamfer = 0.4; // [0:0.1:0.5]

/* [End Coils] */
// Gap between the inner faces of the two end coils at the middle axis
end_gap = 2; // [0.5:0.5:10]
// Radius of the bend that turns the leg toward the middle axis (centerline)
bend_radius = 3; // [1:0.5:10]
// Ratio of the big loop radius to each end coil radius
loop_to_coil_ratio = 2; // [1:0.25:4]
// Vertical distance from the leg end down to the center of each end coil
coil_drop = 9; // [5:0.5:30]

/* [Handle Bars] */
// Angle of each grip bar away from the middle axis
handle_angle = 15; // [0:1:45]
// Radius of the flared root where the stub meets the bar
handle_flare = 6; // [0:0.5:15]
// Length of each grip bar, running back (+Y) from the handle end
bar_length = 40.8; // [5:0.2:80]
// Thickness of each grip bar
bar_thickness = 5; // [2:0.5:15]
// Rounding of the bar corners in the plane of the spring
bar_rounding = 1.5; // [0:0.25:4]

/* [Hidden] */
$fa = $preview ? 16 : 2;
$fs = $preview ? 2 : 0.2;

// Compliance tolerance for parts fitting
tolerance = 0.2;
// Extra gap added to carve-out shapes
epsilon = 0.05;

// Centerline radius of the loop
loop_radius = (loop_diameter - band_width) / 2;
// Where the loop meets the right leg
loop_end = [loop_radius * cos(-loop_end_angle), loop_squash * loop_radius * sin(-loop_end_angle)];
// Heading of the right leg, tangent to the squashed loop
leg_heading = atan2(-loop_squash * cos(loop_end_angle), -sin(loop_end_angle));
// End of the right leg
leg_end = loop_end + leg_length * [cos(leg_heading), sin(leg_heading)];

// Centerline radius of each end coil
coil_radius = loop_radius / loop_to_coil_ratio;
// Centerline x of the coil's inner edge; its inner face stops end_gap/2 short of the axis
tip_x = end_gap / 2 + band_width / 2;
// The bend turns clockwise from the leg direction onto a diagonal toward the axis
bend_center = leg_end + bend_radius * [sin(leg_heading), -cos(leg_heading)];
// The coil turns counterclockwise (opposite to the big loop)
coil_center = [tip_x + coil_radius, leg_end.y - coil_drop];
bend_to_coil = coil_center - bend_center;
assert(norm(bend_to_coil) > bend_radius + coil_radius, "coil_drop is too small for the bend and coil radii");
// Heading of the straight line tangent to both circles, crossing between them
diagonal_heading = atan2(bend_to_coil.y, bend_to_coil.x) - asin((bend_radius + coil_radius) / norm(bend_to_coil));
bend_sweep = posmod(leg_heading + 90 - (diagonal_heading + 90), 360);
assert(bend_sweep < 180, "coil_drop is too large: the bend would wrap into a full ring, lower it");
coil_start = diagonal_heading - 90;
// The coil ends at its bottom heading outward (+X), where the handle continues
coil_sweep = posmod(270 - coil_start, 360);
coil_end = coil_center - [0, coil_radius];
handle_end = coil_end + [handle_length, 0];
// The stub runs into the tilted bar so no gap opens along its slanted inner face
stub_end = handle_end + [band_width * tan(handle_angle) + 1, 0];
// Front-inner corner of the bar, dropped slightly so the stub's lower edge stays inside the bar
bar_corner = [handle_end.x, handle_end.y - band_width / 2 - (stub_end.x - handle_end.x) * tan(handle_angle)];


module see_through(base_color="grey", alpha=0.6) {
    if ($preview) {
        color(base_color, alpha)
            children();
    } else {
        children();
    }
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
// Parts
// ====================================================================

// Right leg, leaving the loop end
function leg_path() = [loop_end, leg_end];

// Right end coil: a bend toward the axis, a straight diagonal, then a counterclockwise coil (opposite to the big loop)
function hook_path() = concat(
    arc(r=bend_radius, cp=bend_center, start=leg_heading + 90, angle=-bend_sweep,
        n=ceil(bend_sweep / 4) + 1),
    arc(r=coil_radius, cp=coil_center, start=coil_start, angle=coil_sweep,
        n=ceil(coil_sweep / 4) + 1)
);

// Right handle stub, leaving the coil end outward into the bar
function handle_path() = [coil_end, stub_end];

// Grip bar leaning away from the middle axis
function bar_outline() =
    move(bar_corner, p=zrot(-handle_angle,
        p=rect([bar_thickness, bar_length], rounding=bar_rounding, anchor=LEFT+FRONT)));

function loop_path() =
    let (angle = 180 + 2 * loop_end_angle)
    yscale(loop_squash, p=arc(r=loop_radius, start=180 + loop_end_angle, angle=-angle, n=ceil(angle / 2) + 1));

// Omega centerline from the left handle over the loop to the right handle
function omega_path() = concat(
    [for (p = reverse(leg_path())) xflip(p=p)],
    select(loop_path(), 1, -2),
    leg_path()
);


// ====================================================================
// Objects
// ====================================================================

// Stub and bar merged, with concave corners filled out into a flared root
function handle_outline() =
    let (merged = union([offset_stroke(handle_path(), width=band_width, start="round", end="flat"),
                         bar_outline()])[0])
    handle_flare > 0 ? offset(offset(merged, r=handle_flare, closed=true), r=-handle_flare, closed=true) : merged;

// Outline of the loop, hooks, stubs and bars, merged so the chamfer runs uninterrupted
function spring_outline() =
    let (right = [
            offset_stroke(hook_path(), width=band_width, start="round", end="round"),
            handle_outline()
        ],
        left = [for (p = right) reverse(xflip(p=p))],
        all = concat([offset_stroke(omega_path(), width=band_width, start="round", end="round")], right, left))
    union(all)[0];

module omega_spring() {
    offset_sweep(spring_outline(), height=spring_height,
                 top=os_chamfer(width=chamfer), bottom=os_chamfer(width=chamfer));
}


// ====================================================================
// Main Assembly & Plates
// ====================================================================
module assembly() {
    mw_plate_1();
}

module mw_plate_1() {
    solid() omega_spring();
}

assembly();
