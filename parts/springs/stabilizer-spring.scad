// A circle with 3 extension springs dampening movements of a smaller inner circle

include <BOSL2/std.scad>

/* [Spring Dimensions] */
// Outer diameter of the outer ring
outer_diameter = 60; // [30:1:150]
// Diameter of the inner circle
inner_diameter = 20; // [5:1:80]
// Number of extension springs
spring_count = 3; // [3:1:6]
// Number of windings per spring
windings = 3; // [1:1:10]
// Amplitude (half of the total width) of each spring's wave
spring_amplitude = 3; // [1:0.5:10]
// Wave squareness: higher values give steeper flanks and longer flat crests
squareness = 2; // [1.5:0.5:10]
// Ring and band width in the plane of the part
band_width = 1.2; // [0.4:0.1:3]
// Part height (extrusion)
part_height = 5; // [1:0.5:20]
// Chamfer on the top and bottom edges
chamfer = 0.4; // [0:0.1:0.5]
// Radius of the bends between crests and flanks (centerline)
bend_radius = 0.8; // [0:0.1:3]
// Length of the short straight handle joining each spring end to its ring
handle_length = 1; // [0:0.5:5]

/* [Hidden] */
$fa = $preview ? 16 : 2;
$fs = $preview ? 2 : 0.2;

// Compliance tolerance for parts fitting
tolerance = 0.2;
// Extra gap added to carve-out shapes
epsilon = 0.05;

// Radial span of one spring's wave, between the two handles
spring_length = (outer_diameter - inner_diameter) / 2 - band_width - 2 * handle_length;
winding_length = spring_length / windings;
// Distance from a zero crossing to where the flank meets the crest
corner_offset = winding_length * asin(1 / squareness) / 360;


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

// Trapezoid wave corners: the flat projection of a helix with flat crests
// Handles overlap the ring walls by epsilon to fuse with them
function wave_corners() = concat(
    [[-handle_length - epsilon, 0], [0, 0]],
    [for (w = [0:windings - 1], p = [
            [corner_offset, 1],
            [winding_length / 2 - corner_offset, 1],
            [winding_length / 2 + corner_offset, -1],
            [winding_length - corner_offset, -1]])
        [w * winding_length + p.x, spring_amplitude * p.y]],
    [[spring_length, 0], [spring_length + handle_length + epsilon, 0]]
);

function wave_path() = round_corners(wave_corners(), radius=bend_radius, closed=false);

module chamfered_ring() {
    tube(h=part_height, od=outer_diameter, wall=band_width,
         ochamfer=chamfer, ichamfer=chamfer, anchor=BOTTOM);
}

module inner_disk() {
    tube(h=part_height, od=inner_diameter, wall=band_width,
         ochamfer=chamfer, ichamfer=chamfer, anchor=BOTTOM);
}

module wave_band() {
    offset_sweep(offset_stroke(wave_path(), width=band_width), height=part_height,
                 top=os_chamfer(width=chamfer), bottom=os_chamfer(width=chamfer));
}

// Full-height blocks that bridge the ring chamfers at both spring ends;
// their faces inside the ring walls stay unchamfered
module joints() {
    joint_length = band_width / 2 + handle_length + epsilon;
    right(inner_diameter / 2 - band_width / 2)
        cuboid([joint_length, band_width, part_height], chamfer=chamfer,
               edges=[TOP, BOTTOM], except=LEFT, anchor=BOTTOM + LEFT);
    right(outer_diameter / 2 - band_width / 2)
        cuboid([joint_length, band_width, part_height], chamfer=chamfer,
               edges=[TOP, BOTTOM], except=RIGHT, anchor=BOTTOM + RIGHT);
}


// ====================================================================
// Objects
// ====================================================================

module stabilizer_spring() {
    chamfered_ring();
    inner_disk();
    for (a = [0:spring_count - 1])
        zrot(a * 360 / spring_count) {
            right(inner_diameter / 2 + handle_length)
                wave_band();
            joints();
        }
}


// ====================================================================
// Main Assembly & Plates
// ====================================================================
module assembly() {
    mw_plate_1();
}

module mw_plate_1() {
    solid() stabilizer_spring();
}

assembly();
