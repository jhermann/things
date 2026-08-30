// Cylindrical grip with a diamond knurl cut from crossed triangular grooves.
//$preview = true;
$fa = $preview ? 16 : 1;
$fs = $preview ? 3 : 0.15;

height = 50;
radius = 15;
base_fn = $preview ? 64 : 128;
groove_count = 24;
groove_width = 1.8;
groove_depth = 1;
groove_overcut = 1;
ring_height = 1.5; // minimum solid, ungrooved band left at each end
groove_angle = 30;

// Circumferential spacing between adjacent grooves of one helix family.
groove_spacing_x = 2 * PI * radius / groove_count;

// Vertical spacing between the diamond corners where the two crossed helix
// families meet (groove_spacing_x / (2 * tan(groove_angle))).
row_pitch = groove_spacing_x / (2 * tan(groove_angle));

// Each ring is rounded up (never thinner) to the next diamond corner, so the
// cylinder meets the pattern at a point rather than slicing through it.
bottom_ring_height = ceil(ring_height / row_pitch) * row_pitch;
top_row_z = floor((height - ring_height) / row_pitch) * row_pitch;
top_ring_height = height - top_row_z;

// Radians-per-height ratio converted to the twist (degrees) needed for a
// helical sweep that crosses the surface at groove_angle from vertical.
groove_twist = height * tan(groove_angle) / radius * 180 / PI;
groove_slices = max(8, ceil(abs(groove_twist) / 15));

// V-shaped notch: wide at the surface, tapering to a point at groove_depth.
module diamond_groove(direction) {
    linear_extrude(
        height = height,
        twist = direction * groove_twist,
        slices = groove_slices,
        convexity = 4
    )
        polygon(points = [
            [radius - groove_depth, 0],
            [radius + groove_overcut, -groove_width / 2],
            [radius + groove_overcut, groove_width / 2]
        ]);
}

module diamond_grooves(direction) {
    for (groove_index = [0 : groove_count - 1])
        rotate([0, 0, groove_index * 360 / groove_count])
            diamond_groove(direction);
}

// Confine the crossed grooves to the mid-section so the top and bottom
// rims stay solid, giving clean, ungrooved ends.
module diamond_grooves_trimmed() {
    intersection() {
        union() {
            diamond_grooves(1);
            diamond_grooves(-1);
        }
        translate([-(radius + groove_overcut), -(radius + groove_overcut), bottom_ring_height])
            cube([2 * (radius + groove_overcut), 2 * (radius + groove_overcut), top_row_z - bottom_ring_height]);
    }
}

module diamond_cylinder() {
    difference() {
        cylinder(r = radius, h = height, $fn = base_fn);
        diamond_grooves_trimmed();
    }
}

diamond_cylinder();
