// Fast preview, smooth final curves
$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.1;

size = 10; // Size of the cube
height = 4; // Height of the cube
chamfer = 1; // Width of the top and bottom chamfers
grid = size * 1.5; // Spacing of the grid

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

union() {
    // rounded vertical edges
    color("red")
    translate([0, 0, 0])
        minkowski() {
            cube([size, size, 1]); // Main body
            cylinder(r=.05 * size, h=1); // The "rounding" tool
        }

    // all edges rounded
    color("green")
    translate([grid, grid, 0])
        minkowski() {
            cube([size, size, 1]); // Main body
            sphere(r=.2 * size); // The "rounding" tool
        }

    // chamfered top/bottom edges
    color("blue")
    translate([-grid, grid, 0])
        chamfered_cube(size, size, height, chamfer);

    // chamfered top/bottom edges with rounded vertical edges
    color("yellow")
    translate([-grid, -grid, 0])
        minkowski() {
            chamfered_cube(size, size, height, chamfer);
            cylinder(r=.05 * size, h=1); // The "rounding" tool
        }
}
