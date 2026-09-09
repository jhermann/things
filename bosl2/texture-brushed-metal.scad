include <BOSL2/std.scad>

/* [Hidden] */
//$preview = true;
local = 1;
$fa = $preview ? 16 : 1;
$fs = $preview ? 2 : 0.1;
//$fn = 96; // Cylinder smoothness (increase for higher texture resolution)

// 1. Generate a pseudo-random 2D heightfield for the texture
// Rows = vertical resolution, Cols = horizontal resolution
rows = 30;
cols = 20;
brushed_noise = [
    for (r = [0:rows-1]) [
        for (c = [0:cols-1]) rands(-0.5, 0.5, 1)[0]
    ]
];

// 2. Render the textured cylinder
cyl(
    d = 90,            // Base diameter of the cylinder (mm)
    h = 30,            // Height of the cylinder (mm)
    texture = brushed_noise,
    tex_inset = false, // false makes the texture protrude outward
    tex_depth = 0.25,   // Depth/height of the brush strokes (keep low for 3D printing)
    // Stretch the texture width (X) to create long brush lines, keep height (Y) small
    tex_size = [30, 2]
);
