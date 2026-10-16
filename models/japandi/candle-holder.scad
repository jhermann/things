// Candle Holder
//
// A pyramidal candle holder: a three-sided pyramid with its tip cut off to
// make room for the candle hole. The lower part is fluted, the upper part
// (as high as the hole is deep) has a rough texture.

include <BOSL2/std.scad>

/* [Main Settings] */
// Side length of the triangular base
base_side = 100; // [60:1:200]
// Total height of the holder
height = 90; // [40:1:200]

/* [Candle Hole] */
// Diameter of the candle hole
hole_diameter = 23; // [10:0.5:60]
// Depth of the candle hole; also the height of the rough section
hole_depth = 30; // [10:1:100]
// Minimal distance to outer wall around the hole, on the flat top surface
top_margin = 3; // [2:0.5:20]

/* [Texture] */
// Chamfer of the bottom edge of the fluted section
bottom_chamfer = 3.5; // [0:0.25:8]
// Chamfer for the hole and body edges
wall_chamfer = 2; // [0:0.25:8]
// Number of flutes on each side
flute_count = 8; // [3:1:20]
// Depth of the flutes at the base (they shrink proportionally towards the top)
flute_depth = 3; // [0.5:0.25:8]
// Depth of the rough texture
rough_depth = 0.4; // [0.1:0.1:2]
// Size of the rough texture pattern
texture_size = 8; // [4:1:20]

/* [Hidden] */
$fa = $preview ? 24 : 4;
$fs = $preview ? 2 : 0.8;

epsilon = 0.05;
tolerance = 0.2;
flute_steps = 8; // profile samples per flute
rough_tex = texture("rough");

// Keep derived calculations below this line,
// so they are hidden from the user interface

// The flat top must hold the hole, the margin around it, and the rough texture
// (which sits on the surface). A triangle's side is 2*sqrt(3) times its inradius.
top_side = sqrt(3) * (hole_diameter + 2 * (top_margin + rough_depth));
// The texture rises above the nominal surface, so the prism is shrunk to keep it within the slope
rough_shrink = 2 * sqrt(3) * rough_depth;
// The hole cannot be deeper than the body (a 2 mm floor is kept)
safe_depth = min(hole_depth, height - 2);
// Where the fluted section ends and the rough section starts
split_z = height - safe_depth;

// Side length at height z, shrinking linearly from the base to the cut-off tip
function side_at(z) = base_side - (base_side - top_side) * z / height;
// Circumradius of an equilateral triangle with the given side
function circumradius(side) = side / sqrt(3);

echo("SIZE side × H:", base_side, height);
echo("TOP side:", top_side);
assert(top_side < base_side, "Base is too small for the candle hole; increase base_side or reduce hole_diameter");

// ====================================================================
// Parts
// ====================================================================

// Triangle outline (corner at +X) with flutes along every side. The flutes are
// zero deep at the corners, so these stay sharp.
function fluted_triangle(r) =
    let(n = flute_count * flute_steps,
        corners = [for (i = [0:2]) r * [cos(120 * i), sin(120 * i)]])
    [for (side = [0:2],
          k = [0:n - 1])
        let(t = k / n,
            from = corners[side],
            to = corners[(side + 1) % 3],
            // Inward direction is towards the triangle centre
            inward = -unit((from + to) / 2),
            depth = flute_depth * (0.5 - 0.5 * cos(360 * flute_count * t)))
        from + t * (to - from) + depth * inward];

// The scaled extrusion keeps all flutes running up the slope
module fluted_section() {
    scale_top = side_at(split_z) / base_side;
    color("#aaa")
    intersection() {
        linear_extrude(height=split_z, scale=scale_top)
            polygon(fluted_triangle(circumradius(base_side)));
        chamfer_hull();
    }
}

// Pyramid hull following the slope, with a 45° chamfer at the bottom edge.
// A triangle's inradius shrinks by c when its side shrinks by 2*sqrt(3)*c.
module chamfer_hull() {
    c = min(bottom_chamfer, split_z - epsilon);
    slice_h = epsilon / 10;
    hull() {
        regular_prism(3, h=slice_h, side=side_at(0) - 2 * sqrt(3) * c, anchor=BOTTOM);
        up(c) regular_prism(3, h=slice_h, side=side_at(c), anchor=BOTTOM);
        up(split_z - slice_h) regular_prism(3, h=slice_h, side=side_at(split_z) + epsilon, anchor=BOTTOM);
    }
}

module rough_section() {
    color($preview ? "red" : "gold")
    up(split_z - epsilon)
    regular_prism(3, h=safe_depth + epsilon,
        side1=side_at(split_z) - rough_shrink, side2=top_side - rough_shrink,
        texture=rough_tex, tex_inset=false, tex_depth=rough_depth,
        tex_size=[texture_size, texture_size], style="min_edge",
        anchor=BOTTOM);
}

module body() {
    fluted_section();
    rough_section();
}

module candle_hole() {
    up(height - safe_depth)
        cyl(h=safe_depth + 1,
            d1=hole_diameter - 2 * tolerance, d2=hole_diameter + tolerance,
            chamfer2=-wall_chamfer, anchor=BOTTOM);
}

// ====================================================================
// Main Assembly
// ====================================================================

module candle_holder() {
    difference() {
        body();
        candle_hole();
    }
}

// ====================================================================
// Plates
// ====================================================================

module assembly() {
    back_half(height + base_side)
    zrot(45)
    candle_holder();
}

module mw_plate_1() {
    candle_holder();
}

if ($preview) assembly();
else mw_plate_1();
