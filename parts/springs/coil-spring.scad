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
// Chamfer on the top and bottom edges
chamfer = 0.3; // [0:0.1:0.5]

/* [Mounting Rings] */
// Diameter of the mounting hole
ring_hole_diameter = 3; // [1:0.5:10]
// Ring wall thickness (must exceed band width)
ring_wall = 1.6; // [1.4:0.1:4]

/* [Hidden] */
$fa = $preview ? 16 : 3;
$fs = $preview ? 2 : 0.5;

// Compliance tolerance for parts fitting
tolerance = 0.2;
// Extra gap added to carve-out shapes
epsilon = 0.05;

ring_outer_radius = ring_hole_diameter / 2 + ring_wall;


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

// Archimedean spiral centerline, starting in the wall of the inner ring
function spiral_path() = path2d(
    helix(h=0, turns=turns, r1=ring_outer_radius - ring_wall / 2, r2=outer_diameter / 2 - band_width / 2)
);

// Centre of the outer ring, continuing along the band's end tangent
function outer_ring_center() =
    let (path = spiral_path(),
         end = last(path),
         tangent = unit(end - path[len(path) - 2]))
    end + tangent * (ring_outer_radius - ring_wall / 2);


// ====================================================================
// Objects
// ====================================================================

module spiral_band() {
    offset_sweep(
        offset_stroke(spiral_path(), width=band_width, closed=false),
        height=spring_height,
        bottom=os_chamfer(width=chamfer),
        top=os_chamfer(width=chamfer)
    );
}

module mounting_ring() {
    tube(h=spring_height, or=ring_outer_radius, id=ring_hole_diameter, chamfer=chamfer, anchor=BOT);
}


// ====================================================================
// Main Assembly & Plates
// ====================================================================
module assembly() {
    mw_plate_1();
}

module mw_plate_1() {
    solid() {
        spiral_band();
        mounting_ring();
        translate(outer_ring_center()) mounting_ring();
    }
}

assembly();
