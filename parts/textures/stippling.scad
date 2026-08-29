// Cylindrical grip with a regular pattern of rounded stipples.
//$preview = true;
$fa = $preview ? 16 : 1;
$fs = $preview ? 3 : 0.15;

height = 50;
radius = 15;
base_fn = $preview ? 64 : 128;
stipple_spacing = 4;
stipple_radius = 0.9;
stipple_height = 0.7;

stipple_rows = ceil(height / stipple_spacing);
stipple_columns = ceil(2 * PI * radius / stipple_spacing);

module stipple(row, column) {
    z = (row + 0.5) * height / stipple_rows;
    angle = column * 360 / stipple_columns + (row % 2) * 180 / stipple_columns;

    rotate([0, 0, angle])
        translate([radius - .5 * stipple_height, 0, z])
            sphere(r = stipple_radius);
}

module stippling() {
    for (row = [0 : stipple_rows - 1])
        for (column = [0 : stipple_columns - 1])
            stipple(row, column);
}

module stippled_cylinder() {
    union() {
        cylinder(r = radius, h = height, $fn = base_fn);
        stippling();
    }
}

stippled_cylinder();
