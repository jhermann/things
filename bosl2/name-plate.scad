// A small box/plate with rounded vertical corners and chamfered top edges.
include <BOSL2/std.scad>

/* [Plate] */
plate_width = 25; // [20:1:200]
plate_depth = 10; // [20:1:200]
plate_height = 1; // [2:0.5:30]
corner_radius = .6; // [0:0.5:20]
edge_chamfer = .3; // [0:0.1:5]

/* [Face Detail] */
recess_depth = .6; // [0:0.1:5]
recess_border = .15; // [0:0.5:20]
label_text = "SAMPLE";
label_size = 3;

/* [Hidden] */
$fa = $preview ? 16 : 1.5;
$fs = $preview ? 2 : 0.1;
epsilon = 0.05;

usable_corner_radius = min(corner_radius, min(plate_width, plate_depth) / 2 - edge_chamfer);
usable_chamfer = min(edge_chamfer, plate_height / 2);


module plate_body() {
    right(plate_width / 2)
    minkowski() {
        cuboid(
            [plate_width, plate_depth, plate_height],
            chamfer=usable_chamfer,
            anchor=BOTTOM
        );
        cylinder(r=usable_corner_radius, h=1); // The "rounding" tool
    }
}

module plate_text(depth = recess_depth, delta = 0) {
    up(depth)
    back(label_size / 2) right(.15 * plate_width)
    xrot(180)
        linear_extrude(height = depth + epsilon) {
            offset(r = delta) {
                text(label_text, font = "Liberation Sans:style=Bold", size = label_size);
            }
        }
}

module name_plate() {
    //factor = (label_size + recess_border) / label_size;

    color("black")
    plate_text();
    //color("lime", alpha=0.5)
	difference() {
		plate_body();
		plate_text(recess_border, recess_border);
	}
}

name_plate();
