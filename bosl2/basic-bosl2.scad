// Basic BOSL2 Example

//$preview = true;
$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.1;

include <BOSL2/std.scad>

// Create the parent object and attach a child
// to the TOP face of the parent.
cuboid([30, 30, 20])
    attach(TOP)
        cylinder(r=5, h=15);
