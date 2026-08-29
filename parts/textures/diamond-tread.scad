// Flat plate with a raised diamond tread pattern.
//$preview = true;
$fa = $preview ? 16 : 1;
$fs = $preview ? 3 : 0.15;

tread_width = 70;
tread_depth = 45;
tread_base_height = 3;
tread_height = 0.8;
diamond_width = 9;
diamond_depth = 4.5;
diamond_spacing_x = 12;
diamond_spacing_y = 8;

module raised_diamond(x, y, orientation = 0) {
    translate([x, y, tread_base_height])
        rotate([0, 0, orientation])
        linear_extrude(height = tread_height)
            polygon(points = [
                [-diamond_width / 2, 0],
                [0, diamond_depth / 2],
                [diamond_width / 2, 0],
                [0, -diamond_depth / 2]
            ]);
}

module diamond_tread_plate() {
    union() {
        cube([tread_width, tread_depth, tread_base_height]);

        intersection() {
            translate([0, 0, tread_base_height])
                cube([tread_width, tread_depth, tread_height]);

            union() {
                for (row = [-1 : ceil(tread_depth / diamond_spacing_y) + 1]) {
                    y = diamond_spacing_y / 2 + row * diamond_spacing_y;
                    row_offset = (row % 2) * diamond_spacing_x / 2;
                    for (column = [-1 : ceil(tread_width / diamond_spacing_x) + 1]) {
                        x = diamond_spacing_x / 2 + column * diamond_spacing_x + row_offset;
                        raised_diamond(x, y, (row + column) % 2 * 90);
                    }
                }
            }
        }
    }
}

diamond_tread_plate();
