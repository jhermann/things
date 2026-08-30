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
wall = 3; // [1:1:10]

/* [Hidden] */
//$preview = true;
$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.1;

// Keep derived calculations below this line,
// so they are hidden from the user interface


module enclosure() {
    difference() {
        // Outer rounded shell
        cuboid([width, length, height], rounding=5, anchor=BOTTOM);

        // Inner cavity hollowed out
        up(wall)
            cuboid([width - (wall * 2), length - (wall * 2), height],
                   rounding=3, anchor=BOTTOM);
    }
}

enclosure();
