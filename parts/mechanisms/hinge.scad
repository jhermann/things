include <BOSL2/std.scad>

/* [Hinge] */
// Outside diameter of the hinge cones
outer_diameter = 25; // [4:0.5:40]
// Inner diameter of the hinge cones
inner_diameter = 15; // [2:0.5:35]
// Overall height of the hinge
height = 15; // [5:1:100]
// Cube size
size = 30; // [1:1:100]

/* [Hidden] */
//$preview = true;
$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.1;

layer_height = 0.2;
tolerance = 0.25;
epsilon = 0.05;

module hinge(outer_diameter=outer_diameter, inner_diameter=inner_diameter, height=height) {
    assert(outer_diameter > inner_diameter, "outer_diameter must be greater than inner_diameter");
    assert(height > 0, "height must be greater than zero");

    radius = outer_diameter / 2;
    cyl_h = (outer_diameter - inner_diameter) / 2 + epsilon;
    gap = height - 2 * cyl_h;

    union() {
        color("red")
        up(gap / 2 - epsilon)
            zcyl(r1=radius, r2=inner_diameter / 2, h=cyl_h, anchor=BOTTOM, chamfer=tolerance);

        color("blue")
            cyl(r=radius, h=gap, chamfer=tolerance);

        color("lime")
        down(gap / 2 - epsilon)
            zcyl(r2=radius, r1=inner_diameter / 2, h=cyl_h, anchor=TOP, chamfer=tolerance);
    }
}


if (1) up(height / 2) {
    if (1)
    difference() {
        union() {
            hinge();
            up(.25 * height)
            cyl(h=1.5 * height, r=inner_diameter / 2, chamfer=tolerance);
        }
        up(layer_height)
        for (angle = [0, 90])
            zrot(angle)
                cuboid([inner_diameter - 8 * layer_height, 2 * layer_height, height - 2 * layer_height]);
    }

    if (1) difference() {
        color("green", alpha=.5)
        minkowski() {
            cuboid([size, size, height - .4 * size]); // Main body
            sphere(r=.2 * size); // The "rounding" tool
        }
        scale((height + 3 * tolerance) / height)
            hinge();
    }
}
