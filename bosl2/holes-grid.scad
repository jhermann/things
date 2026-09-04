// A perforated plate with rounded corners and chamfered top and bottom edges.

include <BOSL2/std.scad>

/* [Plate] */
plate_thickness = 8; // [1:0.5:20]
corner_radius = 8; // [0:0.5:30]
edge_chamfer = .6; // [0:0.1:5]

/* [Hole Grid] */
columns = 7; // [1:1:20]
rows = 4; // [1:1:20]
hole_diameter = 8; // [1:0.5:30]
hole_spacing = 14; // [1:0.5:50]

/* [Hidden] */
$fa = $preview ? 16 : 5;
$fs = $preview ? 2 : 0.5;
edge_gap = .05;

grid_width = (columns - 1) * hole_spacing;
grid_length = (rows - 1) * hole_spacing;
plate_width = grid_width;
plate_length = grid_length;
bevel_height = min(edge_chamfer, plate_thickness / 2);
bevel_width = min(edge_chamfer, plate_width / 2 - corner_radius);
bevel_length = min(edge_chamfer, plate_length / 2 - corner_radius);
hole_bevel = min(edge_chamfer, hole_diameter / 2, plate_thickness / 2);

module chamfered_cube(width, depth, height, chamfer) {
    chamfer = min(chamfer, min(width, depth) / 2, height / 2);

    polyhedron(
        points = [
            [chamfer, chamfer, 0],
            [width - chamfer, chamfer, 0],
            [width - chamfer, depth - chamfer, 0],
            [chamfer, depth - chamfer, 0],
            [0, 0, chamfer],
            [width, 0, chamfer],
            [width, depth, chamfer],
            [0, depth, chamfer],
            [0, 0, height - chamfer],
            [width, 0, height - chamfer],
            [width, depth, height - chamfer],
            [0, depth, height - chamfer],
            [chamfer, chamfer, height],
            [width - chamfer, chamfer, height],
            [width - chamfer, depth - chamfer, height],
            [chamfer, depth - chamfer, height]
        ],
        faces = [
            [0, 1, 2, 3],
            [0, 4, 5, 1],
            [1, 5, 6, 2],
            [2, 6, 7, 3],
            [3, 7, 4, 0],
            [4, 8, 9, 5],
            [5, 9, 10, 6],
            [6, 10, 11, 7],
            [7, 11, 8, 4],
            [8, 12, 13, 9],
            [9, 13, 14, 10],
            [10, 14, 15, 11],
            [11, 15, 12, 8],
            [12, 15, 14, 13]
        ]
    );
}

module hole_grid() {
    grid_copies(spacing=[hole_spacing, hole_spacing], n=[columns, rows])
        cyl(d=hole_diameter, h=plate_thickness + 2 * edge_gap, chamfer=-hole_bevel, anchor=BOTTOM);
}

module perforated_plate() {
    left(hole_spacing * (columns - 1) / 2) fwd(hole_spacing * (rows - 1) / 2)
	difference() {
        // chamfered top/bottom edges with rounded vertical edges
        minkowski() {
            chamfered_cube(plate_width, plate_length, plate_thickness - 2 * edge_chamfer, edge_chamfer);
            cylinder(r=corner_radius, h=1); // The "rounding" tool
        }

        translate([grid_width / 2, grid_length / 2, -edge_gap])
            hole_grid();
	}
}

if (1) perforated_plate();
else hole_grid();
