// BambuLab A1 Mounting Bracket
include <BOSL2/std.scad>

/* [Bracket Dimensions (mm)] */
bracket_thickness = 5; // [3:1:10]
bracket_width = 50; // [10:1:50]
dovetail_depth = 5; // [10:1:30]
dovetail_gap = .6; // [.1:.1:1]

/* [Hidden] */
//$preview = true;
local = 0;
$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.1;

// Manifest dimensions (A1 traversal)
a1_inner_width = 40.5;
a1_inner_height = 20.5;
a1_inner_radius = 5;

wall_thickness = 1.5; // [0.4:0.1:5]
layer_height = 0.2;
tolerance = 0.25;
epsilon = 0.05;
chamfer = 0.3;


// Generates an open 2D path that wraps left/right along the front wall face
function dovetail_flanged_wall_path(width=dovetail_depth / 4, depth=dovetail_depth, angle=45, flange_width=35, tolerance=tolerance) =
    let(
        w_neck = width + (2 * tolerance),
        w_base = w_neck + (2 * depth * tan(angle)),

        // Coordinates for the flanged track running along the face and into the socket:
        p1 = [-w_neck/2 - flange_width, 0], // Far Left Flange (on the face)
        p2 = [-w_neck/2, 0],                // Left Neck Entry
        p3 = [-w_base/2, -depth],           // Deep Left Base
        p4 = [ w_base/2, -depth],           // Deep Right Base
        p5 = [ w_neck/2, 0],                // Right Neck Entry
        p6 = [ w_neck/2 + flange_width, 0]  // Far Right Flange (on the face)
    )
    [p1, p2, p3, p4, p5, p6];


module rounded_layer(size) {
    intersection() {
        cuboid([size, size, epsilon],
               anchor=TOP);
        cuboid([size, size, 4 * wall_thickness],
               rounding=2 * wall_thickness, anchor=TOP);
    }
}


// ====================================================================
// A1 Mounting Bracket
// ====================================================================

module bracket_block(chamfer=0, extend_y=0, extend_z=0) {
    cuboid([bracket_width,
            a1_inner_width + 2 * extend_y,
            a1_inner_height + 2 * extend_z],
           chamfer = chamfer);
}

module dovetail_cutter() {
    dt_path = dovetail_flanged_wall_path(flange_width=a1_inner_height);
    smooth_path = round_corners(dt_path, radius=1.5 * chamfer, closed=false);
    linear_extrude(height=bracket_width, center=true)
        stroke(smooth_path, width=dovetail_gap, closed=false);
}

module a1_bracket() {
    difference() {
        //color("lime", alpha=.3)
            bracket_block(extend_y=bracket_thickness,
                          extend_z=2 * dovetail_depth + bracket_thickness,
                          chamfer=2 * chamfer);

        yrot(90)
        cuboid([a1_inner_height,
                a1_inner_width,
                bracket_width + epsilon],
            chamfer = -chamfer);

        up(a1_inner_height / 2 + 1.5 * dovetail_depth)
            yrot(90) dovetail_cutter();
        down(a1_inner_height / 2 + 1.5 * dovetail_depth)
            yrot(90) dovetail_cutter();
    }
}


// ====================================================================
// Tapo C230 Camera Mount
// ====================================================================

c230_bar_diameter = 44; // [30:1:100]
c230_bar_width = 7; // [3:1:30]
c230_top_diameter = 29; // [10:0.1:50]
c230_bottom_diameter = 31; // [10:0.1:50]
c230_cone_height = 6; // [2:0.25:20]

c230_bar_height = wall_thickness;


module c230_friction_dot(direction=1) {
    up(c230_cone_height - .85 * c230_bar_height)
    fwd(direction * (c230_bar_diameter / 2 - wall_thickness))
    left(direction * (c230_bar_width / 2 - wall_thickness))
        spheroid(r=c230_bar_height / 2);
}

module c230_camera_holder() {
    union() {
        // Twist-lock bar tongues
        up(c230_cone_height)
        intersection() {
            cyl(
                h=c230_bar_height,
                d=c230_bar_diameter,
                anchor=TOP
            );
            up(wall_thickness / 2)
            cuboid([c230_bar_width, c230_bar_diameter, 2 * c230_bar_height],
                   rounding=wall_thickness, anchor=TOP);
        }

        zrot(45) hull() {
            up(c230_cone_height)
                rounded_layer(c230_top_diameter - 4 * wall_thickness);
            up(c230_cone_height - wall_thickness / 2)
                rounded_layer(c230_top_diameter - 2 * wall_thickness);
        }
        zrot(45) hull() {
            up(c230_cone_height - wall_thickness / 2)
                rounded_layer(c230_top_diameter - 2 * wall_thickness);
            rounded_layer(c230_bottom_diameter);
        }

        // Supporting chamfers for the bar
        up(c230_cone_height)
            cuboid([c230_bar_width - wall_thickness / 2,
                    c230_top_diameter + 2 * wall_thickness,
                    2 * wall_thickness],
                   chamfer=wall_thickness, anchor=TOP);

        // Friction dots
        c230_friction_dot(direction=1);
        c230_friction_dot(direction=-1);
    }
}


// ====================================================================
// Main Assembly & Plates
// ====================================================================

module mw_plate_1() {
    up(bracket_width / 2) yrot(90) a1_bracket();
}

module mw_plate_2() {
    up(bracket_width / 2) yrot(90) union() {
        a1_bracket();
        fwd(a1_inner_width / 2 + bracket_thickness - epsilon)
        yrot(90) xrot(90)
        c230_camera_holder();
    }
}

if ($preview || local) { // main assembly in Parametric Model Maker
    mw_plate_1();
}
