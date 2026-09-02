// Cylindrical grip with raised, gently curving vertical ribs.
//$preview = true;
$fa = $preview ? 16 : 1;
$fs = $preview ? 3 : 0.15;

height = 50;
radius = 15;
base_fn = $preview ? 64 : 128;
rib_height = 0.6;
base_radius = radius - 2 * rib_height;
feature_radius = base_radius;
ring_height = 2;
ring_edge_chamfer = 0.4;
rib_count = 72;
rib_angular_width = 360 / rib_count;
rib_width = 2 * PI * feature_radius * rib_angular_width / 360;
profile_radius = rib_width / 2;
wave_amplitude = 10;
wave_count = 2;
rib_slant_angle = -30;
rib_span = height - 2 * ring_height;
rib_length = rib_span / cos(rib_slant_angle);
path_steps = ceil(32 * rib_length / rib_span);
rib_fn = .2;

function rib_angle(index, z) =
    index * 360 / rib_count
    + z * tan(rib_slant_angle) / feature_radius * 180 / PI
    + wave_amplitude * sin(z * wave_count * 360 / height);

function rib_point(index, z) = [
    feature_radius * cos(rib_angle(index, z)),
    feature_radius * sin(rib_angle(index, z)),
    z
];

// Hulled ellipses keep each rib smooth while its centerline follows the wave.
module rib_profile(index, z) {
    translate(rib_point(index, z))
        rotate([0, 0, rib_angle(index, z)])
            scale([rib_height, profile_radius, rib_width / 2])
                sphere(r = 1, $fn = rib_fn);
}

module wavy_rib(index) {
    for (step = [0 : path_steps - 1]) {
        z0 = ring_height
            + (height - 2 * ring_height) * step / path_steps;
        z1 = ring_height
            + (height - 2 * ring_height) * (step + 1) / path_steps;
        hull() {
            rib_profile(index, z0);
            rib_profile(index, z1);
        }
    }
}

module wavy_ribs() {
    for (rib = [0 : rib_count - 1])
        wavy_rib(rib);
}

module chamfered_base() {
    cylinder(r = base_radius, h = height, $fn = base_fn);
}

module chamfer_rings() {
    for (z = [0, height - ring_height])
        rotate_extrude($fn = base_fn)
            polygon(points = [
                [feature_radius - rib_height + ring_edge_chamfer, z],
                [feature_radius + rib_height - ring_edge_chamfer, z],
                [feature_radius + rib_height, z + ring_edge_chamfer],
                [feature_radius + rib_height, z + ring_height - ring_edge_chamfer],
                [feature_radius + rib_height - ring_edge_chamfer, z + ring_height],
                [feature_radius - rib_height + ring_edge_chamfer, z + ring_height],
                [feature_radius - rib_height, z + ring_height - ring_edge_chamfer],
                [feature_radius - rib_height, z + ring_edge_chamfer]
            ]);
}

module waves_cylinder() {
    union() {
        chamfered_base();
        chamfer_rings();
        wavy_ribs();
    }
}

waves_cylinder();
