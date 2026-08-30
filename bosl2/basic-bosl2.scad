// Basic BOSL2 Example
include <BOSL2/std.scad>

/* [Main Settings] */
// The size of the cube
cube_size = 30; // [20:1:150]

// The size of the cube
tube_radius = 5; // [5:1:25]
tube_height = 15; // [10:1:50]

// The primary layout shape
cube_type = "round"; // [round, square]

/* [Hidden] */
// Keep derived calculations down here so they do not clutter the MakerWorld UI

//$preview = true;
$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.1;

// Create the parent object and attach a child
// to the TOP face of the parent.
cuboid([cube_size, cube_size, cube_size], box_type=cube_type)
    attach(TOP)
        cylinder(r=tube_radius, h=tube_height, center=true);
