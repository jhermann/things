// Pen Holder
//
// A cylindrical pen holder with a filleted inner floor.

include <BOSL2/std.scad>

/* [Main Settings] */
// Outer diameter of the holder
outer_diameter = 65; // [40:1:150]
// Total height of the holder
height = 90; // [40:1:200]
// Height of upper rim
rim_height = 7; // [0:1:200]
// Radius of the ribs around the main body
rib_radius = 1; // [0.25:0.25:9]
// Position of the transition line (in percent of height)
transition_pos = 50; // [5:5:95]
// Angle of the transition line between rough and ribbed surfaces
transition_angle = 20; // [0:1:45]

/* [Walls and Edges] */
// Wall thickness of the holder
wall_thickness = 1.5; // [1.25:0.25:10]
// Floor thickness below the fillet
floor_thickness = 2.5; // [1:0.2:10]
// Radius of the fillet between inner floor and inner wall
floor_fillet = 8; // [0.4:0.2:30]
// Rounding of the outer bottom edge
bottom_rounding = 1.25; // [0:0.25:10]
// Size of the texture pattern
texture_size = 8; // [4:1:20]

/* [Hidden] */
//$preview = true;
local = 0;
$fa = $preview ? 24 : 4;
$fs = $preview ? 2 : 0.8;

tolerance = 0.2;
epsilon = 0.05;

tex = texture("rough");

// Keep derived calculations below this line,
// so they are hidden from the user interface

inner_diameter = outer_diameter - 2 * wall_thickness;
inner_height = height - floor_thickness;
// The fillet cannot exceed the inner radius or the cavity height
safe_fillet = min(floor_fillet, inner_diameter / 2 - 0.1, inner_height - 0.1);

echo("SIZE H × D:", height, outer_diameter);
echo("INNER D:", inner_diameter);

// ====================================================================
// Parts
// ====================================================================

module ribs() {
    // Max ribs on the circle of radius D/2 without overlapping:
    // adjacent centers are 2*(D/2)*sin(180/n) apart, which must be >= 2*rib_radius
    rib_count = floor(180 / asin(2 * rib_radius / outer_diameter));
    echo("ribs:", rib_count);

    intersection() {
        union() {
            zrot_copies(n=rib_count)
            left(outer_diameter / 2)
            cyl(h=height - rim_height, r=rib_radius, anchor=BOTTOM);
        }

        cyl(h=height - rim_height,
            d=outer_diameter + 2 * rib_radius,
            chamfer1=bottom_rounding + rib_radius, anchor=BOTTOM);
    }
}

// Outer body, rounded at the bottom edge only
module body() {
    slant_factor = .99;
    rib_start = transition_pos / 100 * height;

    // Outer body
    color("#aaa")
    cyl(h=height - rim_height,
        d1=outer_diameter,
        d2=slant_factor * outer_diameter,
        chamfer1=bottom_rounding, anchor=BOTTOM);

    // Slanted lower part of the outer body
    difference() {
        color("#aaa")
        cyl(h=rib_start, d=outer_diameter + 2 * rib_radius,
            texture=tex,
            tex_inset=false,
            tex_depth=0.10,
            tex_size=[texture_size, texture_size], style="min_edge",
            chamfer1=bottom_rounding + rib_radius, anchor=BOTTOM);

        // Cuts off the upper part
        //color("red")
        up(rib_start + tolerance)
        yrot(transition_angle)
        cuboid([2 * outer_diameter, 2 * outer_diameter, sin(transition_angle) * outer_diameter + 2 * tolerance]);
    }

    // Ribs around the main body
    color("#aaa")
        ribs();

    // Rim at the top of the main body
    color($preview ? "red" : "black")
    up(height - rim_height)
    union() {
        zcyl(h=rim_height - 0.10, d=outer_diameter + 2 * rib_radius,
            texture=tex,
            tex_inset=false,
            tex_depth=0.10,
            tex_size=[texture_size, texture_size], style="min_edge",
            rounding2=wall_thickness / 3, anchor=BOTTOM);
        zcyl(h=rim_height, d=outer_diameter + 2 * rib_radius,
            rounding2=wall_thickness / 3, anchor=BOTTOM);
    }
}

// Cavity with its bottom edge rounded, which leaves a concave fillet
// on the inner floor of the finished holder
module cavity() {
    up(floor_thickness)
        cyl(h=inner_height + 1, d=inner_diameter, rounding1=safe_fillet, anchor=BOTTOM);

    up(height + epsilon)
        cyl(h=rim_height, d=inner_diameter, rounding2=-wall_thickness / 4, anchor=TOP);
}

// ====================================================================
// Main Assembly
// ====================================================================

module pen_holder() {
    difference() {
        body();
        cavity();
    }
}

// ====================================================================
// Plates
// ====================================================================

module assembly() {
    back_half(2.5 * height) mw_plate_1();
}

module mw_plate_1() {
    zrot(-90)
    pen_holder();
}

if ($preview || local) {
    if ($preview) assembly();
    else mw_plate_1();
}
