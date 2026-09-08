/*  BOSL2 Attachments Example

    The BOSL2 attachment system lets you position and orient child geometry
    relative to a parent using anchors instead of manual coordinates.

    Key concepts:
    - Anchors define reference points on the parent and child geometry.
    - The `attach()` function positions the child relative to the parent using these anchors.
    - The `overlap` parameter controls how much the child intersects the parent.

    https://github.com/BelfrySCAD/BOSL2/wiki/attachments.scad
*/
include <BOSL2/std.scad>

box_size = [20, 20, 15];
hole_depth = 10;
hole_diameter = 4;
head_diameter = 11;
head_slope = .33;

$fn = 64;
tolerance = .15;
epsilon = .05;

diff()
cube(box_size)
    attach(TOP, overlap=-epsilon) {
        zscale(head_slope)
        tag("remove") cyl(
            d=hole_diameter + tolerance,
            h=hole_depth / head_slope,
            chamfer=-(head_diameter - hole_diameter)/2 - tolerance,
            anchor=TOP);
    }
