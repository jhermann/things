// Attachment Examples
include <BOSL2/std.scad>

$fa = $preview ? 16 : .25;
$fs = $preview ? 2 : .1;
epsilon = .05;
chamfer = .3;

module cube_with_bottom_hole(size=20, hole=10, depth=10) {
    diff() {
        cuboid([size, size, size], anchor=BOT, chamfer=chamfer)
        attach(FRONT, overlap=-epsilon)
            tag("remove")
            zcyl(d1=.75 * hole, d2=1.25 * hole, h=depth,
                 anchor=TOP, chamfer2=-chamfer);
    }

}

cube_with_bottom_hole();
