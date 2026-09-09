include <BOSL2/std.scad>

/* [Hidden] */
//$preview = true;
local = 1;
$fa = $preview ? 16 : 1;
$fs = $preview ? 2 : 0.1;
//$fn = 96; // Cylinder smoothness (increase for higher texture resolution)

tex = texture("rough");

cyl(
    d = 90,            // Base diameter of the cylinder (mm)
    h = 30,            // Height of the cylinder (mm)
    texture = tex,
    tex_inset = false, // false makes the texture protrude outward
    tex_depth = 0.15,   // Depth/height of the brush strokes (keep low for 3D printing)
    tex_size = [5, 55], style="min_edge"
);
