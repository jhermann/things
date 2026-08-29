// Cylindrical grip with evenly spaced vertical ribs.
//$preview = true;
$fa = $preview ? 16 : 1;
$fs = $preview ? 3 : 0.15;

height = 50;
radius = 15;
base_fn = $preview ? 64 : 128;
rib_count = 36;
rib_width = 1;
rib_height = .75;
rib_corner_radius = 0.25;

module rounded_rib() {
    translate([radius, 0, 0])
        linear_extrude(height = height)
        minkowski() {
            square([
                rib_height - 2 * rib_corner_radius,
                rib_width - 2 * rib_corner_radius
            ], center = true);
            circle(r = rib_corner_radius, $fn = 12);
        }
}

module ribbing() {
    for (rib = [0 : rib_count - 1])
        rotate([0, 0, rib * 360 / rib_count])
            rounded_rib();
}

// Encircling band matching the rib's radial and vertical thickness.
module rib_ring(z_center) {
    translate([0, 0, z_center])
        rotate_extrude($fn = base_fn)
        translate([radius, 0, 0])
        minkowski() {
            square([
                rib_height - 2 * rib_corner_radius,
                rib_width - 2 * rib_corner_radius
            ], center = true);
            circle(r = rib_corner_radius, $fn = 12);
        }
}

module rib_rings() {
    rib_ring(rib_width / 2);
    rib_ring(height - rib_width / 2);
}

module ribbed_cylinder() {
    union() {
        cylinder(r = radius, h = height, $fn = base_fn);
        ribbing();
        rib_rings();
    }
}

ribbed_cylinder();
