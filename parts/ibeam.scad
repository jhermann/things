// A simple I-beam

include <BOSL2/std.scad>

/* [Hidden] */
//$preview = true;
local = 0;
$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.1;

wall_thickness = 1.5; // [0.4:0.1:5]
layer_height = 0.2;
tolerance = 0.25;
epsilon = 0.05;
chamfer = 0.3;

function eps(dim) = (dim + epsilon) / dim;

// rotational extrusion of an ellipsoid with its center at `radius`
module ibeam(length, width, height, wall=1.5) {
    union() {
        difference() {
            cuboid([length, width, height], chamfer=chamfer);
            xrot(90)
            cuboid([length + epsilon, height - 2 * wall + epsilon, width + epsilon], chamfer=-chamfer, edges="X");
        }

        difference() {
            cuboid([length, 2 * wall, height - 2 * wall + 2 * epsilon], chamfer=-4 * chamfer, edges="X");
            cuboid([length - 2 * wall, 1.5 * layer_height, height]);
        }
    }
}

up(30) yrot(90)
ibeam(60, 20, 10);
