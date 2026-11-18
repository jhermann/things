// Round dowel with fins
include <BOSL2/std.scad>

/* [Hidden] */
//$preview = true;
$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.1;

layer_height = 0.2;
tolerance = 0.25;
epsilon = 0.05;
chamfer = 0.3;

// Generates a 2D list of points representing a fluted dowel profile
function make_dowel_poly(d=8, flute_count=8, flute_depth=0.6, flute_width=1.2, tolerance=0.2) =
    let(
        r = (d / 2) + tolerance, // Base cutter radius including slop
        base_circle = circle(r=r, $fn=120) // Generate base 2D path points
    )
    // Map over the circle points to subtract the flutes geometrically
    [for (p = base_circle)
        let(
            angle = atan2(p.y, p.x),
            // Check if the current angle falls into a flute window
            flute_spacing = 360 / flute_count,
            rel_angle = (angle + 180) % flute_spacing,
            half_fw_angle = (flute_width / (2 * PI * r)) * 360,

            // Adjust radius inward if inside a flute area
            in_flute = (rel_angle < half_fw_angle) || (rel_angle > flute_spacing - half_fw_angle),
            curr_r = in_flute ? r - flute_depth : r
        )
        [curr_r * cos(angle), curr_r * sin(angle)]
    ];

dowel_poly = make_dowel_poly(d=8, flute_count=6, tolerance=0.15);
offset_sweep(
    dowel_poly,
    height=32,
    bottom=os_chamfer(width=0.5),
    top=os_chamfer(width=0.5),
);
