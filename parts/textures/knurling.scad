// Tall cylindrical grip with crossed helical knurling.
//$preview = true;
$fa = $preview ? 16 : 1;
$fs = $preview ? 3 : 0.15;

height = 50;
radius = 15;
base_fn = $preview ? 64 : 128;
knurl_pitch = 7;
knurl_ribs = 18;
knurl_width = 1.2;
knurl_height = 0.9;

turns = height / knurl_pitch;

module helical_rib(direction) {
    linear_extrude(
        height = height,
        twist = direction * 360 * turns,
        slices = ceil(turns * 24),
        convexity = 4
    )
        translate([radius + knurl_height / 2, 0, 0])
            square([knurl_height, knurl_width], center = true);
}

module knurling(direction) {
    for (rib = [0 : knurl_ribs - 1])
        rotate([0, 0, rib * 360 / knurl_ribs])
            helical_rib(direction);
}

module knurled_cylinder() {
    union() {
        cylinder(r = radius, h = height, $fn = base_fn);
        knurling(1);
        knurling(-1);
    }
}

knurled_cylinder();
