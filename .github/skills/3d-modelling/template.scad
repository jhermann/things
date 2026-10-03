// <NAME OF THE MODEL>
//
// <SUMMARY DESCRIPTION OF THE MODEL; IDEALLY BASED ON USER INPUT AND SPECIFICATIONS>

include <BOSL2/std.scad>

/* [Main Settings] */
// The width of the enclosure
width = 40; // [20:1:150]
// The length of the enclosure
length = 60; // [20:1:150]
// The height of the enclosure
height = 30; // [20:1:150]

// The wall thickness of the enclosure
wall_thickness = 2; // [1:1:10]
// Chamfer applied to walls
wall_chamfer = .6; // [0.5:0.1:2]

/* [Hidden] */
//$preview = true;
local = 1;
$fa = $preview ? 32 : 4;
$fs = $preview ? 4 : 0.2;

// Clearance added to joining pieces
tolerance = 0.2;
// Extra size added to carve-out shapes
epsilon = 0.05;
// Font family for text engraving
font_family = "Helvetica:style=Bold";
// Surface texture
tex = texture("rough");

plate_grid_spacing = [1.2 * width, 1.2 * length];

// Keep derived calculations below this line,
// so they are hidden from the user interface


echo("SIZE H × L × W:", height, length, width);

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



// ====================================================================
// Main Assembly & Plates
// ====================================================================

module enclosure() {
    difference() {
        // Outer rounded shell
        cuboid([width, length, height], rounding=5, anchor=BOTTOM);

        // Inner cavity hollowed out
        up(wall_thickness)
            cuboid([width - (wall_thickness * 2), length - (wall_thickness * 2), height],
                   rounding=3, anchor=BOTTOM);
    }
}


// ====================================================================
// Plates
// ====================================================================
module assembly() {
    grid_copies(spacing=plate_grid_spacing, n=[2, 1])
        if ($idx == 0)
            mw_plate_1();
        else if ($idx == 1)
            mw_plate_2();
}

module mw_plate_1() {
    enclosure();
}

module mw_plate_2() {
    enclosure();
}

if ($preview || local) { // main assembly in Parametric Model Maker
    if ($preview) mw_plate_1();
    else assembly();
}
