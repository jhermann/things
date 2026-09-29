// The projection of a helical extension spring to a flat object

include <BOSL2/std.scad>

/* [Spring Dimensions] */
// Length of the spring between its end anchors
spring_length = 60; // [20:1:200]
// Amplitude (half of the total width) of the zigzag
spring_amplitude = 6; // [2:0.5:20]
// Number of full windings
windings = 6; // [2:1:20]
// Wave squareness: higher values give steeper flanks and longer flat crests
squareness = 2; // [1.5:0.5:10]
// Band width in the plane of the spring
band_width = 1.2; // [0.4:0.1:3]
// Spring height (extrusion)
spring_height = 5; // [1:0.5:20]
// Chamfer on the top and bottom edges
chamfer = 0.4; // [0:0.1:0.5]
// Radius of the bends between crests and flanks (centerline)
bend_radius = 1.5; // [0:0.1:3]
// Length of the straight handle attached to each end, along the X axis
handle_length = 8; // [0:1:30]

/* [Hidden] */
$fa = $preview ? 16 : 2;
$fs = $preview ? 2 : 0.2;

// Compliance tolerance for parts fitting
tolerance = 0.2;
// Extra gap added to carve-out shapes
epsilon = 0.05;

winding_length = spring_length / windings;
// Distance from a zero crossing to where the flank meets the crest
corner_offset = winding_length * asin(1 / squareness) / 360;


module see_through(base_color="grey") {
    if ($preview) {
        color(base_color, 0.6)
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
function wave_corners() = concat(
    [[-handle_length, 0], [0, 0]],
    [for (w = [0:windings - 1], p = [
            [corner_offset, 1],
            [winding_length / 2 - corner_offset, 1],
            [winding_length / 2 + corner_offset, -1],
            [winding_length - corner_offset, -1]])
        [w * winding_length + p.x, spring_amplitude * p.y]],
    [[spring_length, 0], [spring_length + handle_length, 0]]
);

function wave_path() = round_corners(wave_corners(), radius=bend_radius, closed=false);


// ====================================================================
// Objects
// ====================================================================

module wave_band() {
    offset_sweep(offset_stroke(wave_path(), width=band_width), height=spring_height,
                 top=os_chamfer(width=chamfer), bottom=os_chamfer(width=chamfer));
}


// ====================================================================
// Main Assembly & Plates
// ====================================================================
module assembly() {
    mw_plate_1();
}

module mw_plate_1() {
    solid() wave_band();
}

assembly();
