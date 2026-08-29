// Japandi-inspired cylinder with quiet, organic vertical ripples.
$preview = true;
$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.15;

height = 40;
radius = 25;
wall = 2.5;
segments = 24;
path_steps = 18;
groove_radius = 1;

japandi_cylinder();

// A softly wandering centerline for one recessed ripple.
function ripple_angle(index, z) =
    index * 360 / segments
    + 5 * sin(z * 360 / height + index * 37)
    + 2 * sin(z * 720 / height - index * 19);

function ripple_point(index, z) = [
    (radius - groove_radius * 0.25) * cos(ripple_angle(index, z)),
    (radius - groove_radius * 0.25) * sin(ripple_angle(index, z)),
    z
];

// Hulling neighboring spheres makes a continuous, rounded groove cutter.
module ripple_cutter(index) {
    for (step = [0 : path_steps - 1]) {
        z0 = height * step / path_steps;
        z1 = height * (step + 1) / path_steps;
        hull() {
            translate(ripple_point(index, z0))
                sphere(r = groove_radius);
            translate(ripple_point(index, z1))
                sphere(r = groove_radius);
        }
    }
}

module ripple_cutters() {
    for (index = [0 : segments - 1])
        ripple_cutter(index);
}

module japandi_cylinder() {
    difference() {
        // Slightly softened silhouette, with a usable open interior.
        union() {
            cylinder(r = radius - 0.8, h = 0.8);
            cylinder(r = radius, h = height - 0.8);
            cylinder(r = radius - 0.8, h = height);
        }

        // Hollow from below while retaining a solid base.
        translate([0, 0, 2.4])
            cylinder(r = radius - wall, h = height);

        ripple_cutters();
    }
}
