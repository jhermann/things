// Hull examples
//
// Three typical uses of `hull()`: a stadium-shaped plate spanning two round
// ends, a hollow square-to-round adapter, and a smooth bracket blending a
// base plate into an offset post. Each part sits flat on the Z=0 print plane,
// one part per plate.

include <BOSL2/std.scad>

/* [Stadium Plate] */
// Distance between the two end centers
plate_span = 40; // [20:1:80]
// Diameter of the end caps
plate_diameter = 14; // [8:1:30]
// Thickness of the plate
plate_thickness = 3; // [1:0.2:10]

/* [Adapter] */
// Edge length of the square bottom opening
adapter_square = 30; // [20:1:60]
// Outer diameter of the round top
adapter_round = 18; // [10:1:50]
// Height of the adapter
adapter_height = 25; // [10:1:60]
// Wall thickness of the adapter
wall_thickness = 2; // [1:0.2:5]

/* [Bracket] */
// Edge length of the square base plate
bracket_base = 24; // [15:1:50]
// Thickness of the base plate
bracket_base_thickness = 3; // [2:0.2:8]
// Diameter of the post at the top
bracket_post = 8; // [4:1:20]
// Horizontal offset of the post from the base center
bracket_offset = 6; // [0:1:20]
// Height of the post top above the plate
bracket_height = 22; // [10:1:50]

/* [Hidden] */
//$preview = true;
local = 1;
$fa = $preview ? 32 : 4;
$fs = $preview ? 4 : 0.2;

// Extra size added to carve-out shapes
epsilon = 0.05;
// Corner rounding of the square shapes
corner_rounding = 3;
// Thin slice used as a hull anchor for flat profiles
slice = 0.01;

// Distance between the plates in the assembly view
plate_grid_spacing = [45, 45];

// Keep derived calculations below this line,
// so they are hidden from the user interface

echo("STADIUM PLATE:", plate_span, plate_diameter, plate_thickness);
echo("ADAPTER:", adapter_square, adapter_round, adapter_height);
echo("BRACKET:", bracket_base, bracket_height);

// ====================================================================
// Helpers
// ====================================================================

module see_through(base_color="grey", alpha=0.6) {
    if ($preview) {
        color(base_color, alpha=alpha)
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


// ====================================================================
// Parts
// ====================================================================

// Two discs joined by hull() make a stadium-shaped plate
module stadium_plate() {
    hull()
        xcopies(plate_span)
            cyl(d=plate_diameter, h=plate_thickness, rounding=0.5, anchor=BOTTOM);
}

// A thin square slice at the bottom and a thin disc at the top; the hull
// blends between them, so a smaller copy subtracted gives a hollow adapter
module adapter_shape(square_size, round_d, h) {
    hull() {
        cuboid([square_size, square_size, slice], rounding=corner_rounding,
               edges="Z", anchor=BOTTOM);
        up(h - slice)
            cyl(d=round_d, h=slice, anchor=BOTTOM);
    }
}

module adapter() {
    difference() {
        adapter_shape(adapter_square, adapter_round, adapter_height);
        // Inner cavity, extended past both ends for a clean cut
        down(epsilon)
            adapter_shape(adapter_square - 2 * wall_thickness,
                          adapter_round - 2 * wall_thickness,
                          adapter_height + 2 * epsilon);
    }
}

// Base plate hulled with an offset post: the hull creates the smooth
// sloped flank without manual polyhedron work
module bracket() {
    hull() {
        cuboid([bracket_base, bracket_base, bracket_base_thickness],
               rounding=corner_rounding, edges="Z", anchor=BOTTOM);
        right(bracket_offset)
            up(bracket_height - slice)
                cyl(d=bracket_post, h=slice, anchor=BOTTOM);
    }
}

// ====================================================================
// Main Assembly & Plates
// ====================================================================

module assembly() {
    grid_copies(spacing=plate_grid_spacing, n=[3, 1])
        if ($idx == 0)
            mw_plate_1();
        else if ($idx == 1)
            mw_plate_2();
        else if ($idx == 2)
            mw_plate_3();
}

module mw_plate_1() {
    stadium_plate();
}

module mw_plate_2() {
    adapter();
}

module mw_plate_3() {
    bracket();
}

if ($preview || local) { // main assembly in Parametric Model Maker
    if ($preview) mw_plate_1();
    else assembly();
}
