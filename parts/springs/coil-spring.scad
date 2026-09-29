// A spiral spring for storing energy

include <BOSL2/std.scad>

/* [Spring Dimensions] */
// Outer diameter of the spiral
outer_diameter = 40; // [20:1:100]
// Number of turns
turns = 4; // [1:0.5:10]
// Band width in the plane of the spiral
band_width = 1.2; // [0.4:0.1:3]
// Spring height (extrusion)
spring_height = 5; // [1:0.5:20]

/* [Hidden] */
$fa = $preview ? 16 : 1;
$fs = $preview ? 2 : 0.1;

// Compliance tolerance for parts fitting
tolerance = 0.2;
// Extra gap added to carve-out shapes
epsilon = 0.05;

// Radial distance between neighbouring turns
turn_pitch = (outer_diameter / 2 - band_width) / turns;
spiral_steps = ceil(turns * 72);


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

// Archimedean spiral centerline, growing outwards from the origin
function spiral_path() = [
    for (i = [0:spiral_steps])
        let (a = 360 * turns * i / spiral_steps,
             r = turn_pitch * turns * i / spiral_steps + band_width / 2)
        [r * cos(a), r * sin(a)]
];


// ====================================================================
// Objects
// ====================================================================

module spiral_band() {
    linear_extrude(height=spring_height, convexity=10)
        stroke(spiral_path(), width=band_width);
}


// ====================================================================
// Main Assembly & Plates
// ====================================================================
module assembly() {
    mw_plate_1();
}

module mw_plate_1() {
    solid() spiral_band();
}

assembly();
