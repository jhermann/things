// A tall squarish bar with chamfers, that can be placed where two wall meet;
// with a vertical screw hole from the top, and a horizontal side slot for the nut at its lower end.

// TODO: Use incremental bridging planes to build a flatter roof for the nut slot

include <BOSL2/std.scad>

/* [Post Dimensions] */
// Post size along the X axis
post_size = 10; // [10:1:50]
// Post height along the Z axis
post_height = 30; // [15:1:150]
// Chamfer on all edges of the post
chamfer = .5; // [0:0.25:4]

/* [Screw and Nut] */
// Screw shank diameter (M3 = 3)
screw_diameter = 3; // [2:0.1:8]
// Nut width across the flats (M3 = 5.5)
nut_width = 5.5; // [3:0.1:14]
// Nut thickness (M3 = 2.4)
nut_thickness = 2.4; // [1:0.1:8]
// How far the retention bumps at the slot entrance protrude from each side wall
nut_lip = 0.3; // [0:0.05:1]
// Screw length measured from the underside of the screw head to the tip
screw_length = 20; // [5:0.5:150]
// Thickness of the lid attached to the top face, which lifts the screw head
lid_thickness = 2; // [0:0.5:10]

/* [Hidden] */
$fa = $preview ? 16 : 2;
$fs = $preview ? 2 : 0.2;

// Clearance added around the screw and nut
tolerance = 0.2;
// Extra size added to carve-out shapes
edge_pad = 0.05;
// Length of the nut retention bumps along the slot
nut_lip_length = 0.8;

// Nut width across the corners
nut_corners = nut_width / cos(30);
// Z of the screw tip, which is where the nut slot starts
screw_tip_z = post_height + lid_thickness - screw_length;
// Z of the bottom of the screw hole, leaving room for the screw to pass through the nut
hole_bottom_z = screw_tip_z - 2 * nut_thickness;
// Z of the flat roof of the nut slot
slot_roof_z = screw_tip_z + nut_thickness + tolerance / 2;
// Distance from the screw axis to the post's vertical edge where the slot opens
edge_dist = post_size * sqrt(2) / 2;
// Rise of the 45° roof, from the far side of the nut up to the post edge
roof_height = (edge_dist + (nut_corners + tolerance) / 2) / sqrt(2);

assert(hole_bottom_z > tolerance, "screw_length must be shorter than post_height plus lid_thickness minus two nut thicknesses");
assert(slot_roof_z + roof_height < post_height, "screw_length is too short to fit the nut slot roof below the post top");

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

module post_body() {
    cuboid([post_size, post_size, post_height], chamfer=chamfer, except=BOTTOM);
    // Negative chamfer: flares outward at the bottom
    if (chamfer > 0)
        down(post_height / 2)
            cuboid([post_size, post_size, chamfer], chamfer=-chamfer, edges=BOTTOM, anchor=BOTTOM);

    leg = post_size + 2 * chamfer;
    e = edge_pad;

    // Extrudes a profile given as [distance outward from the hypotenuse, z] along the hypotenuse
    module along_hypotenuse() {
        translate([-leg / 2, -leg / 2, 0])
            zrot(225)
                rotate([90, 0, 0])
                    linear_extrude(height=leg * sqrt(2), center=true)
                        children();
    }

    translate([post_size / 2, post_size / 2, -post_height / 2])
        difference() {
            union() {
                linear_extrude(height=post_height)
                    polygon([[0, 0], [-leg, 0], [0, -leg]]);
                // Negative chamfer: flares outward at the bottom
                along_hypotenuse()
                    polygon([[-chamfer, 0], [chamfer, 0], [0, chamfer], [-chamfer, chamfer]]);
            }
            // Normal chamfer at the top
            along_hypotenuse()
                polygon([[e, post_height - chamfer - e], [e, post_height + e], [-chamfer - e, post_height + e]]);
        }
}

// Vertical shank hole from the top face down to two nut thicknesses below the nut slot
module screw_hole() {
    translate([0, 0, hole_bottom_z])
        cyl(d=screw_diameter + tolerance, h=post_height - hole_bottom_z + edge_pad, anchor=BOTTOM);
}

// Horizontal hex nut pocket at the screw tip that opens onto the +X side
module nut_slot() {
    // Bumps on both side walls just outside the seated nut, so it must be pressed past them
    module lip() {
        flat_half = (nut_corners + tolerance) * sin(60) / 2;
        for (s = [-1, 1])
            translate([(nut_corners + tolerance) / 2, s * flat_half, screw_tip_z + nut_thickness / 2])
                cuboid([nut_lip_length, 2 * nut_lip, nut_thickness + tolerance + 2 * edge_pad], anchor=LEFT);
    }

    module footprint(h) {
        hull() {
            cyl(d=nut_corners + tolerance, h=h);
            translate([post_size, 0, 0])
                cyl(d=nut_corners + tolerance, h=h);
        }
    }

    translate([0, 0, screw_tip_z + nut_thickness / 2])
        footprint(nut_thickness + tolerance);

    // Quarter pyramid apexed above the post edge, so the roof rises at 45° and prints without support
    translate([0, 0, slot_roof_z - edge_pad])
        intersection() {
            translate([edge_dist, 0, 0])
                cyl(r1=(roof_height + edge_pad) * sqrt(2), r2=0, h=roof_height + edge_pad, $fn=4, anchor=BOTTOM);
            up((roof_height + edge_pad) / 2)
                footprint(roof_height + edge_pad);
        }
}


// ====================================================================
// Objects
// ====================================================================

module screw_post() {
    if ($preview) {
        solid("red")
            screw_hole();
        solid("crimson")
            zrot(-90 - 45)
            nut_slot();
    }

    see_through("lime", alpha=.1)
    difference() {
        up(post_height / 2)
        post_body();
        screw_hole();
        zrot(-90 - 45)
        nut_slot();
    }
}


// ====================================================================
// Main Assembly & Plates
// ====================================================================
module assembly() {
    mw_plate_1();
}

module mw_plate_1() {
    screw_post();
}

assembly();
