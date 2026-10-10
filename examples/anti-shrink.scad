// Hollow chamfered box
//
// A simple open-top box with chamfered outside edges.

include <BOSL2/std.scad>

/* [Box Settings] */
width = 50; // [20:1:150]
length = 40; // [20:1:150]
height = 15; // [10:1:100]

/* [Wall Settings] */
wall_thickness = 2; // [1:0.5:10]
bottom_thickness = 2; // [1:0.5:10]
edge_chamfer = 1.2; // [0.5:0.1:5]

/* [Hidden] */
$fa = $preview ? 32 : 4;
$fs = $preview ? 4 : 0.2;
epsilon = 0.05;

module see_through(base_color = "lime", alpha = 0.05) {
    if ($preview) {
        color(base_color, alpha)
            children();
    } else {
        children();
    }
}

module solid(base_color = "red", alpha = 1) {
    if ($preview) {
        color(base_color, alpha)
            children();
    } else {
        children();
    }
}

module groove(height, length) {
    half_base = height;

    intersection() {
        solid()
        down(epsilon) xrot(90) down(length / 2)
            offset_sweep(
                path = [
                    [-half_base, 0],
                    [half_base, 0],
                    [0, height],
                ],
                height = length);

        up(height / 2 - epsilon)
        hull() {
            fwd(length / 2 - height)
                cyl(r = height + epsilon, h = height + 2 * epsilon);
            back(length / 2 - height)
                cyl(r = height + epsilon, h = height + 2 * epsilon);
        }
    }
}

module box_grooves() {
    function inner(x) =  (x - 2 * wall_thickness);
    x_angle = atan(inner(width) / inner(length));
    x_length = sqrt(inner(width)^2 + inner(length)^2);
    w2 = 2 * wall_thickness;
    ec2 = edge_chamfer / 2;

    union() {
        zrot(x_angle) groove(ec2, x_length);
        zrot(180 - x_angle) groove(ec2, x_length);

        up(bottom_thickness + epsilon)
        difference() {
            solid()
            cuboid([width - w2, length - w2, ec2], anchor=TOP);

            cuboid([width - w2 - .66 * edge_chamfer, length - w2 - .66 * edge_chamfer, 2 * edge_chamfer]);
        }
    }
}

module box() {
    if ($preview) box_grooves();

    difference() {
        see_through()
        cuboid([width, length, height], chamfer=edge_chamfer, anchor=BOTTOM);

        // Cavity
        up(bottom_thickness)
            cuboid([width - 2 * wall_thickness,
                    length - 2 * wall_thickness,
                    height + epsilon],
                   anchor=BOTTOM);

        // The shinkinking force relieve
        box_grooves();
    }
}

box();
//box_grooves();
