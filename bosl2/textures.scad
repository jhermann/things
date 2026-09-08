include <BOSL2/std.scad>

grid = 50;

// Generates a 3D block with a diamond knurled pattern pressed into the sides
left(grid)
cyl(d=30, h=25,
    texture="diamonds",    // Select the built-in pattern
    tex_size=[3, 4],       // Width and height of one repeating tile (in mm)
    tex_depth=1,           // Depth of the pattern (negative values invert it)
    tex_inset=true,        // Lowers the texture into the block to preserve outer bounds
    anchor=BOTTOM
);

// 1. Define a 2D matrix of height maps (values between 0 and 1)
// This creates a custom ridge pattern
custom_pattern = [
    [0.0, 0.5, 1.0, 0.5, 0.0],
    [0.0, 0.5, 1.0, 0.5, 0.0],
    [0.0, 0.5, 1.0, 0.5, 0.0],
    [0.0, 0.5, 1.0, 0.5, 0.0]
];

// 2. Extrude a shape while applying the custom heightfield to the sides
linear_sweep(
    square([20, 20], center=true),
    h=30,
    texture=custom_pattern,
    tex_size=[4, 4] // Scale of the grid in mm
);

// more... https://github.com/BelfrySCAD/BOSL2/wiki/skin.scad
