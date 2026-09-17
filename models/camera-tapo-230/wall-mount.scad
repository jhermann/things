// Tapo C230 Camera Wall Mount
include <BOSL2/std.scad>

/* [Holder Dimensions (mm)] */
plate_diameter = 55; // [30:1:100]
bar_diameter = 44; // [30:1:100]
bar_width = 7; // [3:1:30]
top_diameter = 29; // [10:0.1:50]
bottom_diameter = 31; // [10:0.1:50]
cone_height = 6; // [2:0.25:20]
wall_thickness = 1.5; // [0.4:0.1:5]
hole_distance = 28; // [20:1:60]
hole_size = 4; // [3:1:6]

/* [Hidden] */
//$preview = true;
$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.1;

layer_height = 0.2;
tolerance = 0.25;
epsilon = 0.05;

inner_top_diameter = top_diameter - 2 * wall_thickness;
inner_bottom_diameter = bottom_diameter - 2 * wall_thickness;
bar_height = wall_thickness;

assert(top_diameter > 2 * wall_thickness);
assert(bottom_diameter > 2 * wall_thickness);
assert(cone_height > 0);


module rounded_layer(size) {
    intersection() {
        cuboid([size, size, epsilon],
               anchor=TOP);
        cuboid([size, size, 4 * wall_thickness],
               rounding=2 * wall_thickness, anchor=TOP);
    }
}

module friction_dot(direction=1) {
    color("yellow")
    up(cone_height - .85 * bar_height)
    fwd(direction * (bar_diameter / 2 - wall_thickness))
    left(direction * (bar_width / 2 - wall_thickness))
        spheroid(r=bar_height / 2);
}

module camera_holder() {
    union() {
        // Twist-lock bar tongues
        up(cone_height)
        intersection() {
            color("red")
            cyl(
                h=bar_height,
                d=bar_diameter,
                anchor=TOP
            );
            up(wall_thickness / 2)
            cuboid([bar_width, bar_diameter, 2 * bar_height],
                   rounding=wall_thickness, anchor=TOP);
        }

        zrot(45) hull() {
            up(cone_height)
                rounded_layer(top_diameter - 4 * wall_thickness);
            up(cone_height - wall_thickness / 2)
                rounded_layer(top_diameter - 2 * wall_thickness);
        }
        zrot(45) hull() {
            up(cone_height - wall_thickness / 2)
                rounded_layer(top_diameter - 2 * wall_thickness);
            rounded_layer(bottom_diameter);
        }

        // Supporting chamfers for the bar
        color("blue")
        up(cone_height)
            cuboid([bar_width - wall_thickness / 2, top_diameter + 2 * wall_thickness, 2 * wall_thickness],
                   chamfer=wall_thickness, anchor=TOP);

        // Main cone
        if (0)
        color("lime", alpha=.3)
        cyl(
            h=cone_height,
            d1=bottom_diameter,
            d2=top_diameter,
            anchor=BOTTOM
        );

        // Plate
        if (1)
        up(epsilon)
        difference() {
            color("orange") zrot(180 / 8)
                regular_prism(n=8, h=2 * wall_thickness + epsilon, r=plate_diameter / 2, chamfer=tolerance, anchor=TOP);

                back(hole_size / 2)
                grid_copies(n=[2, 2], spacing=hole_distance) {
                    up(epsilon)
                    teardrop(h=6 * wall_thickness + epsilon,
                        d=hole_size, orient=BACK, anchor=TOP);
            }
        }

        // Friction dots
        friction_dot(direction=1);
        friction_dot(direction=-1);
    }
}

up(plate_diameter * cos(180 / 8) / 2) xrot(90)
camera_holder();
