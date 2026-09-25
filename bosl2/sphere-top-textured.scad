include <BOSL2/std.scad>

/* [Hidden] */
//$preview = true;
$fa = $preview ? 16 : 1;
$fs = $preview ? 2 : 0.1;
//$fn = 96;

tex = texture("rough");

sp_d = 90;        // Diameter of the full sphere (mm)
sp_r = sp_d / 2;
cap_h = sp_d / 4; // Height of the remaining top cap (top 1/4 of the sphere)

// Revolving a half-circle arc produces a full sphere; top_half() then keeps only the top cap.
top_half(z = sp_r - cap_h)
    rotate_sweep(
        arc(r = sp_r, angle = [-90, 90]),
        texture = tex,
        caps = true,
        tex_inset = false, // false makes the texture protrude outward
        tex_depth = 0.15,   // Depth/height of the brush strokes (keep low for 3D printing)
        tex_size = [5, 55], style="min_edge"
    );
