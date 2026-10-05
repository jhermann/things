// Heat-insert hole with concentric rings of radial slits
//
// A parametric cutter for a heat-set insert hole. Narrow radial slits around
// the hole add perimeter paths when the surrounding part is sliced.

include <BOSL2/std.scad>

/* [Heat Insert Hole] */
hole_diameter = 4.7; // [2:0.1:10]
hole_depth = 6; // [5:1:30]
slit_width = 0.2; // [0.2:0.1:1]
slit_length = 0.8; // [0.4:0.1:2]
slits_per_ring = 24; // [8:4:48]
concentric_rings = 2; // [1:1:6]
ring_pitch = 1.2; // [0.6:0.1:3]
slit_end_clearance = 0.4; // [0.2:0.1:1]

/* [Hidden] */
//$preview = true;
local = 1;
$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.1;

tolerance = 0.2;
epsilon = 0.05;
sample_block_width = max(
    18,
    hole_diameter + 2 * ((concentric_rings - 1) * ring_pitch + slit_length + 3)
);
sample_block_height = hole_depth + 3;


module see_through(base_color="grey", alpha=0.6) {
    if ($preview) {
        color(base_color, alpha=alpha)
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

module heat_insert_hole(depth=hole_depth, diameter=hole_diameter) {
    union() {
        cyl(d=diameter, h=depth + epsilon, anchor=BOTTOM);

        up(depth / 2 - slit_end_clearance)
        for (ring = [0 : concentric_rings - 1]) {
            zrot(360 / slits_per_ring / 2 * ring)
            zrot_copies(
                n=slits_per_ring,
                r=diameter / 2 + ring * ring_pitch + 2.5 * tolerance
            )
                up(slit_end_clearance)
                cuboid([slit_length, slit_width, depth - 2 * slit_end_clearance], anchor=LEFT);
        }
    }
}

// ====================================================================
// Main Assembly
// ====================================================================

module sample_hole() {
    up(sample_block_height - hole_depth)
        heat_insert_hole();
}

module sample_block() {
    if ($preview) solid() sample_hole();

    difference() {
        see_through("lime", alpha=0.25)
        cuboid(
            [sample_block_width, sample_block_width, sample_block_height],
            anchor=BOTTOM
        );
        sample_hole();
    }
}

if ($preview || local)
    sample_block();
