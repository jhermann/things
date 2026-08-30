// Plug and hole that keep two cuboids together.
//
// The plug is a vertical cylinder that fits into a hole
// in the other cuboid, providing stability and alignment.
// The plug is designed to be sturdy and easy to print,
// with a slight taper for easy insertion.
// Same goes for the hole, which is designed to be
// complementary to the plug.
//
// The plug also has a slightly angled outer hull so it
// can easily enter the hole, but then provides a very good
// fit once fully inserted. The hole has vertical walls,
// and the plug outer diameter varies from slightly smaller
// at  the top to slightly thicker at its bottom.
//
// To create extra strength and flexing for tolerance compliance,
// the outer wall of the plug is ribbed by cutting empty tubes
// around its circumference. Also, a cross-shaped hollow space goes
// through the plug to add extra walls, enforcing strength of the part.
// That cross-shaped hollow space penetrates the part (cuboid) the plug
// connects, to give it more protections from separations at the joint.

//$preview = true;
$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.1;

// Cuboid dimensions
width = 30;
depth = 30;
height = 15;
spacing = 40; // Gap between the two cubes

// Plug: tapers from a thick base to a thinner tip for easy starting insertion
plug_height = 10;
plug_radius = 5;
plug_variance = .25;
plug_wall_thickness = 1.5;

// Hole: vertical walls sized around the plug's tip, so the fit tightens
// as the thicker part of the plug is pushed in
hole_clearance = 0.05;
hole_radius = plug_radius + hole_clearance;
hole_depth = plug_height + 1;

// Cross-shaped hollow through the plug, continuing down into its cuboid.
// Sized against the tip (the plug's narrowest point) so a wall of
// plug_wall_thickness remains before the hollow would break the outer wall.
cross_arm_thickness = .66 * plug_wall_thickness;
cross_arm_length = 2 * (plug_radius - 1.25 * plug_wall_thickness);
cross_depth = plug_height + height * 0.6;

// Chamfer applied to the plug's base, its tip, the hole's outer rim,
// and the bottom perimeter of both cuboids
chamfer_size = plug_wall_thickness / 3;

// Ribs cut into the plug's outer wall for flex, sized and placed so they
// only cut halfway through plug_wall_thickness instead of breaking the wall.
// Pulled back from the bottom so the base chamfer stays solid.
rib_count = 10;
rib_radius = 0.5 * plug_wall_thickness;
rib_offset = plug_radius - plug_wall_thickness / 2 + rib_radius;
rib_height = plug_height - chamfer_size;

// Derived dimensions
plug_tip_radius = plug_radius - plug_variance / 2;
plug_base_radius = plug_radius + plug_variance / 2;

module tapered_plug() {
    // Profile flares out at the base and cuts a flat corner at the tip
    rotate_extrude()
        polygon(points = [
            [0, 0],
            [plug_base_radius + chamfer_size, 0],
            [plug_base_radius, chamfer_size],
            [plug_tip_radius, plug_height - chamfer_size],
            [plug_tip_radius - chamfer_size, plug_height],
            [0, plug_height]
        ]);
}

module cross_hollow(length, depth) {
    // "+" shaped void made of two crossed slots
    union() {
        cube([length, cross_arm_thickness, depth], center = true);
        cube([cross_arm_thickness, length, depth], center = true);
    }
}

module chamfered_base_cuboid(w, d, h, chamfer) {
    // Bevels the bottom perimeter by hulling a smaller footprint at z=0
    // up to the full footprint at z=chamfer
    hull() {
        translate([chamfer, chamfer, 0])
            cube([w - 2 * chamfer, d - 2 * chamfer, 0.001]);
        translate([0, 0, chamfer])
            cube([w, d, h - chamfer]);
    }
}

module plug_ribs() {
    for (i = [0 : rib_count - 1])
        rotate([0, 0, i * 360 / rib_count])
            translate([rib_offset, 0, 0])
                cylinder(h = rib_height, r = rib_radius);
}

module plug_cuboid() {
    difference() {
        union() {
            chamfered_base_cuboid(width, depth, height, chamfer_size);
            translate([width / 2, depth / 2, height])
                tapered_plug();
        }
        translate([width / 2, depth / 2, height + plug_height - cross_depth / 2])
            cross_hollow(cross_arm_length, cross_depth);
        translate([width / 2, depth / 2, height + chamfer_size])
            plug_ribs();
    }
}

module hole_cuboid() {
    difference() {
        chamfered_base_cuboid(width, depth, height, chamfer_size);
        translate([width / 2, depth / 2, height - hole_depth])
            cylinder(h = hole_depth + 0.1, r = hole_radius);
        // Chamfer the outer rim of the hole
        translate([width / 2, depth / 2, height - chamfer_size])
            cylinder(h = chamfer_size, r1 = hole_radius, r2 = hole_radius + chamfer_size);
    }
}

plug_cuboid();

translate([-spacing, -spacing, 0])
    hole_cuboid();
