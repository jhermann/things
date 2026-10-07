include <BOSL2/std.scad>

/* [Hidden] */
//$preview = true;
$fa = $preview ? 16 : 1;
$fs = $preview ? 2 : 0.1;
//$fn = 96;

tex = texture("rough");

sp_d = 90;        // Diameter of the full sphere (mm)
sp_r = sp_d / 2;
cap_h = sp_d / 5; // Height of the cap
chamfer = 0.3;
skin_depth = 0.15;

cut_angle = asin((sp_r - cap_h) / sp_r);


color("orange")
    rotate_sweep(
        arc(r = sp_r, angle = [cut_angle, 90]),
        texture = tex,
        caps = true,
        tex_inset = false, // false makes the texture protrude outward
        tex_depth = skin_depth,   // Depth/height of the brush strokes (keep low for 3D printing)
        tex_size = [5, 55], style="min_edge",
        anchor=BOTTOM
    );

color("lime")
    cyl(h = 1, r = sqrt(sp_r^2 - (sp_r - cap_h)^2) + skin_depth,
        chamfer1 = chamfer, anchor=TOP);
