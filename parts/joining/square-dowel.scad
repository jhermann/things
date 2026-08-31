// Square dowel and its mating diagonal half-cube groove.
//
// The dowel is a flat, chamfered square block. The groove is that same
// dowel cross section, tipped 45° so it stands on one corner (the opposite
// corner topmost), sunk more than halfway into a half-height cube, and
// swept diagonally corner to corner across its top. Two such half-cubes,
// joined along their diagonal edge, would sandwich a full dowel between
// them to align and reinforce the seam.

include <BOSL2/std.scad>

/* [Square Dowel] */
// Side length of the dowel's square footprint
dowel_size = 10; // [5:1:40]
// Thickness of the dowel (its flat height)
dowel_thickness = 3; // [2:0.5:15]
// Chamfer applied to the dowel's top and bottom edges
dowel_chamfer = .75; // [0.5:0.5:5]

/* [Half-Cube Part] */
// Size of the full cube this block is half the height of
cube_size = 25; // [20:5:100]
// Gap added around the hole, and sunk past the halfway line, for a slip fit
edge_gap = 0.15; // [0:0.05:1]

/* [Hidden] */
//$preview = true;
$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.1;

half_height = cube_size / 2;
// Extends past both corners so the cut fully crosses the top face
groove_length = cube_size * sqrt(2) + dowel_size;

spacing = .75 * cube_size; // Gap between demo objects


module see_through(base_color="grey") {
    if ($preview) {
        color(base_color, 0.6)
            children();
    } else {
        children();
    }
}

module solid(base_color="red") {
    if ($preview) {
        color(base_color)
            children();
    } else {
        children();
    }
}

module square_dowel(gap=0) {
    shift = .25 * dowel_size;
    protrude = .75 * dowel_chamfer + gap;
    bump_diameter = 1.5 * dowel_thickness;
    module bump() {
        // Pokes 2*edge_gap past the top face as a lead-in bump
        solid() up(protrude / 2)
            spheroid(d = [bump_diameter, bump_diameter, dowel_thickness + protrude / 2], anchor = BOTTOM);
    }

    // union() so callers can safely use this as a single solid (e.g. in difference())
    union() {
        left(shift) fwd(shift)
            bump();
        right(shift) back(shift)
            bump();

        // Chamfers on all top/bottom edges let the flat bar slide into its groove
        see_through()
        cuboid([dowel_size + edge_gap, dowel_size + edge_gap, dowel_thickness + edge_gap],
               chamfer = dowel_chamfer, edges = [TOP, BOTTOM], anchor = BOTTOM);
    }
}

module half_cube(slot_angle=45) {
    module slot(angle=0) {
        // The dowel's own profile, tipped onto a corner and sunk past the
        // halfway line by edge_gap so the two halves overlap for a snug fit
        up(half_height)
            zrot(45 + angle) xrot(90)
                down(dowel_thickness / 2) zrot(45)
                    square_dowel(edge_gap);
    }
    difference() {
        cuboid([cube_size, cube_size, half_height], anchor = BOTTOM);
        slot(slot_angle);
        slot(slot_angle + 180);
    }
}

left(spacing)
    square_dowel();

right(spacing) {
    fwd(2 * spacing)
        see_through("green") half_cube(0);
    see_through("blue") up(cube_size / 2) xrot(180) half_cube(0);
    back(2 * spacing) up(cube_size / 2) see_through("yellow") xrot(90) half_cube(45);
}
