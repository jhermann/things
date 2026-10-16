// LED Tealight Holder
//
// A tealight candle holder with a spheroid hull
// (outer shape is the vertical middle slice of a sphere).

include <BOSL2/std.scad>

/* [Main Settings] */
// Total height of the holder
height = 30; // [40:1:200]
// Outer diameter at the widest point (the middle)
diameter = 64; // [40:1:200]
// Angle of the slice taken out of the sphere to form the wall (degrees)
slice_angle = 50; // [20:1:120]

/* [Tealight Hole] */
// Diameter of the tealight hole
hole_diameter = 39.5; // [10:0.5:60]
// Depth of the tealight hole
hole_depth = 25; // [5:1:100]
// Chamfer of the hole's top edge
wall_chamfer = 2; // [0:0.25:8]
// Add "LED" hint text?
led_hint = true; // [true,false]

/* [Flutes] */
// Number of flutes around the holder
flute_count = 48; // [3:1:60]
// Depth of the flutes at the widest point (they scale with the radius)
flute_depth = 2.5; // [0.5:0.25:8]
// Size of the transition where the flutes round into the top (at least the flute depth)
flute_chamfer = 2.75; // [0:0.25:8]

/* [Hidden] */
$fa = $preview ? 24 : 2;
$fs = $preview ? 2 : 0.2;

epsilon = 0.05;
tolerance = 0.2;
flute_steps = $preview ? 48 : 96; // angular samples per flute
profile_steps = $preview ? 48 : 96; // samples along the arc
font_family = "Impact";
emboss_size = 12;
emboss_height = wall_chamfer / 2;

// Keep derived calculations below this line,
// so they are hidden from the user interface

// The wall arc has this radius and spans slice_angle as seen from its centre
arc_radius = height / (2 * sin(slice_angle / 2));
// The arc centre lies on the Z axis only if the arc radius equals the outer radius,
// so it is offset radially to make height, diameter, and angle independent
arc_offset = diameter / 2 - arc_radius;
// Radius of the flat top and bottom faces
end_radius = arc_offset + arc_radius * cos(slice_angle / 2);
// The hole cannot be deeper than the body (a 2 mm floor is kept)
safe_depth = min(hole_depth, height - 2);

// Outer radius at height z (z = 0 is the bottom)
function arc_radius_at(z) =
    arc_offset + sqrt(max(0, sqr(arc_radius) - sqr(z - height / 2)));

// Flute depth at height z (flutes scale with the radius)
function flute_depth_at(z) = flute_depth * arc_radius_at(z) / (diameter / 2);

// Radius limit that lets the flutes grow out of the flat ends. Both ends are full
// circles at the flute valley radius; the limit widens from there, so the flutes
// fade in without any overhang. The bottom is a 45° chamfer, the top a concave quarter-round
// that ends in a vertical tangent, with the top edge rounded by wall_chamfer. The round is at least as large as the flute depth.
function edge_limit(z) =
    let(base = end_radius - flute_depth_at(0),
        c = max(flute_chamfer, flute_depth_at(0)),
        w = wall_chamfer,
        dt = height - z,
        // Convex fillet of radius w rounds the edge to the flat top; the concave
        // flute transition continues below it with a matching vertical tangent
        top = dt < w ? base - w + sqrt(max(0, sqr(w) - sqr(w - dt)))
            : dt < w + c ? base + c - sqrt(max(0, sqr(c) - sqr(dt - w)))
            : 1e9)
    min(base + z, top);

echo("SIZE Ø × H:", diameter, height);
echo("ARC radius:", arc_radius, "END Ø:", 2 * end_radius);
assert(slice_angle < 180, "slice_angle must be below 180");
assert(edge_limit(height) > hole_diameter / 2 + wall_chamfer + 0.5,
    "Flat ends are too small for the tealight hole; increase diameter or slice_angle, or reduce hole_diameter");

// ====================================================================
// Parts
// ====================================================================

// Spheroid body with chamfered bottom, rounded top, and flutes that bend along the arc of the wall. The flutes
// scale with the radius, so they vanish towards the ends only as far as the
// hull narrows.
module fluted_hull() {
    n = flute_count * flute_steps;
    rows = [for (i = [0:profile_steps])
        // Cosine spacing samples the chamfer and rounding at the ends more densely
        let(z = height * (1 - cos(180 * i / profile_steps)) / 2,
            r = arc_radius_at(z),
            d = flute_depth_at(z),
            lim = edge_limit(z))
        [for (k = [0:n - 1])
            let(a = 360 * k / n,
                rr = min(r - d * (0.5 - 0.5 * cos(flute_count * a)), lim))
            [rr * cos(a), rr * sin(a), z]]];

    color("#aaa")
    vnf_polyhedron(vnf_vertex_array(rows, caps=true, col_wrap=true, row_wrap=false, reverse=true));
}

module tealight_hole() {
    up(height - safe_depth)
        cyl(h=safe_depth + 1,
            d1=hole_diameter - tolerance,
            d2=hole_diameter + 2 * tolerance,
            chamfer1=wall_chamfer / 2, chamfer2=-wall_chamfer, anchor=BOTTOM);
}

module led_label() {
    up(height - safe_depth - emboss_height + epsilon)
    color("red") xscale(1.25)
        linear_extrude(height=emboss_height + epsilon)
            text("LED!", size=emboss_size, font=str(font_family, ":style=Bold"),
                halign="center", valign="center");
}

// ====================================================================
// Main Assembly
// ====================================================================

module tealight_holder() {
    difference() {
        fluted_hull();
        tealight_hole();
        if (led_hint) led_label();
    }
}

// ====================================================================
// Plates
// ====================================================================

module assembly() {
    back_half(height + diameter)
    tealight_holder();
}

module mw_plate_1() {
    tealight_holder();
}

if ($preview) assembly();
else mw_plate_1();
