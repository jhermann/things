// Two bands forming a leaf spring for absorbing shocks or making opposite parts flex

include <BOSL2/std.scad>

/* [Spring Dimensions] */
// Distance between the ring attachment points at the center of a leaf pair
spring_length = 50; // [20:1:150]
// Height of each leaf's outward bulge
leaf_bulge = 8; // [1:0.5:20]
// Distance between the two leaves of a pair
leaf_spacing = 3; // [1:0.5:10]
// Band thickness
band_thickness = 1.2; // [0.4:0.1:3]
// Spring height (extrusion)
spring_height = 8; // [1:0.5:30]
// Chamfer on the top and bottom edges
chamfer = 0.4; // [0:0.1:0.5]

/* [Rings] */
// Outer diameter of the two small rings
ring_diameter = 16; // [8:1:40]
// Wall thickness of the rings
ring_wall = 2; // [1:0.5:5]
// Distance of each leaf pair from the ring axis line
pair_offset = 4.5; // [2:0.5:15]

/* [Hidden] */
$fa = $preview ? 16 : 2;
$fs = $preview ? 2 : 0.2;

// Compliance tolerance for parts fitting
tolerance = 0.2;
// Extra gap added to carve-out shapes
epsilon = 0.05;

// Band ends sit at the ring wall's mid-radius
ring_mid_radius = ring_diameter / 2 - ring_wall / 2;
ring_center_x = spring_length / 2 + ring_attach_x(pair_offset);


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

// X distance from a ring's center to where a band at height y meets its mid-radius
function ring_attach_x(y) = sqrt(pow(ring_mid_radius, 2) - y * y);

// A single band at height y between the rings, bulging towards +Y
function band_region(y) =
    let (
        len = 2 * (ring_center_x - ring_attach_x(y)),
        r = (pow(len / 2, 2) + pow(leaf_bulge, 2)) / (2 * leaf_bulge),
        angle = 2 * asin(len / 2 / r),
        path = arc(r=r, cp=[0, y - (r - leaf_bulge)], start=90 - angle / 2, angle=angle,
                   n=ceil(angle) + 1)
    ) [offset_stroke(path, width=band_thickness)];

function ring_region(x) = right(x, p=[circle(d=ring_diameter), circle(d=ring_diameter - 2 * ring_wall)]);

// Two parallel leaves bowing towards +Y
function leaf_pair_regions() = [
    for (d = [-1, 1])
        band_region(pair_offset + d * leaf_spacing / 2)
];

function leaf_spring_region() = union(concat(
    leaf_pair_regions(),
    [for (r = leaf_pair_regions()) yflip(p=r)],
    [for (x = [-ring_center_x, ring_center_x]) ring_region(x)]
));


// ====================================================================
// Objects
// ====================================================================

module leaf_spring() {
    offset_sweep(leaf_spring_region(), height=spring_height,
                 top=os_chamfer(width=chamfer), bottom=os_chamfer(width=chamfer));
}


// ====================================================================
// Main Assembly & Plates
// ====================================================================
module assembly() {
    mw_plate_1();
}

module mw_plate_1() {
    solid() leaf_spring();
}

assembly();
