// Lamp shade
//

include <BOSL2/std.scad>

/* [Base + Shade Dimensions] */
// Maximal diameter of the LED puck
led_puck_diameter = 82; // [25:1:120]
// Maximal height of the LED puck
led_puck_height = 21; // [10:5:40]
// Lamp base height
base_height = 40; // [1:0.5:10]
// Lamp shade height
shade_height = 140; // [30:5:200]
// Wall thickness of the lamp base and shade
wall_thickness = 2.5; // [0.5:0.25:3]
// Corner radius for the lamp base and shade
lamp_corner_radius = 15; // [0:1:25]
// Chamfer applied to the lamp base's top and bottom edges
lamp_chamfer = .75; // [0.5:0.25:2]
// Cable diameter for the lamp base's cable slot
cable_diameter = 3; // [1:0.5:10]
// Lug size
lug_size = 5; // [1:0.5:10]

/* [Hidden] */
//$preview = true;
local = 1;
$fa = $preview ? 16 : 1;
$fs = $preview ? 2 : 0.1;

// Compliance tolerance for parts fitting
tolerance = 0.2;
// Extra gap added to carve-out shapes
epsilon = 0.05;
// Font family for text engraving
Font_family = "Helvetica:style=Bold";

led_insert_diameter = led_puck_diameter + 2 * (wall_thickness);
base_size = led_insert_diameter + 2 * (wall_thickness + lug_size + 2 * tolerance);
led_insert_height = led_puck_height + wall_thickness + 2 * tolerance;
lug_radius = led_insert_diameter / 2;
cable_sweep_angle = (180 / PI * 1.25 * cable_diameter / lug_radius);

shade_size = 1.5 * base_size;
shade_wall_thickness = wall_thickness;

echo("OUTER base diameter:", base_size);
echo("OUTER holder diameter:", led_insert_diameter);


module see_through(base_color="grey") {
    if ($preview) {
        color(base_color, 0.6)
            children();
    } else {
        children();
    }
}

module solid(base_color="red") {
    if ($preview) {
        color(base_color)
            children();
    } else {
        children();
    }
}


// ====================================================================
// Parts
// ====================================================================

module chamfered_cube(width, depth, height, chamfer) {
    chamfer = min(chamfer, min(width, depth) / 2, height / 2);

    polyhedron(
        points = [
            [chamfer, chamfer, 0],
            [width - chamfer, chamfer, 0],
            [width - chamfer, depth - chamfer, 0],
            [chamfer, depth - chamfer, 0],
            [0, 0, chamfer],
            [width, 0, chamfer],
            [width, depth, chamfer],
            [0, depth, chamfer],
            [0, 0, height - chamfer],
            [width, 0, height - chamfer],
            [width, depth, height - chamfer],
            [0, depth, height - chamfer],
            [chamfer, chamfer, height],
            [width - chamfer, chamfer, height],
            [width - chamfer, depth - chamfer, height],
            [chamfer, depth - chamfer, height]
        ],
        faces = [
            [0, 1, 2, 3],
            [0, 4, 5, 1],
            [1, 5, 6, 2],
            [2, 6, 7, 3],
            [3, 7, 4, 0],
            [4, 8, 9, 5],
            [5, 9, 10, 6],
            [6, 10, 11, 7],
            [7, 11, 8, 4],
            [8, 12, 13, 9],
            [9, 13, 14, 10],
            [10, 14, 15, 11],
            [11, 15, 12, 8],
            [12, 15, 14, 13]
        ]
    );
}

module shade_cap(
        width = shade_size - lamp_corner_radius,
        cap_height = 5,
        bump_height = 4,
        box_height = .6,
        corner_radius = lamp_corner_radius,
        chamfer_size = lamp_chamfer * 2 / 3) {
    hull() {
        translate([-width / 2, -width / 2, 0])
            minkowski() {
                cube([width, width, box_height]);
                cylinder(r=corner_radius, h=box_height / 2);
            }
        translate([0, 0, cap_height])
            scale([.75 * width, .75 * width, bump_height])
                sphere(d=1);
    }

    hull() {
        // ---- CHAMFERED & ROUNDED BOX BASE ----
        translate([-width / 2, -width / 2, 0]) {
            hull() {
                // 1. The main lower body of the box
                minkowski() {
                    cube([width, width, box_height - chamfer_size]);
                    cylinder(r=corner_radius, h=0.01); // minimal height to keep math clean
                }

                // 2. The inset top face (creates the 45-degree chamfer)
                translate([chamfer_size, chamfer_size, box_height - 0.01])
                minkowski() {
                    cube([width - 2*chamfer_size, width - 2*chamfer_size, 0.01]);
                    cylinder(r=corner_radius, h=0.01);
                }
            }
        }

        // ---- TOP SPHERE BUMP ----
        translate([0, 0, cap_height])
            scale([.75 * width, .75 * width, bump_height])
                sphere(d=1);
    }
}

module shade_struts(width = shade_size) {
    strut_size = width / 2;
    strut_shift = shade_size * sqrt(2) - 2 * strut_size + 4 * lamp_corner_radius + epsilon;

    up(shade_height)
    for (angle = [45 : 90: 360])
        zrot(-angle) fwd(strut_shift)
        yrot(-90)
        linear_extrude(height = wall_thickness / 2, center = true)
            polygon([
                //[-lamp_corner_radius, 0],
                //[-strut_size, 0],
                [0, 0],
                [-strut_size, 0],
                [0, strut_size],
            ]);
}

module lamp_body() {
    fwd(shade_size / 2) left(shade_size / 2)
    minkowski() {
        chamfered_cube(shade_size, shade_size, shade_height, lamp_corner_radius / 2);
        cylinder(r=lamp_corner_radius, h=1); // The "rounding" tool
    }
}

// ====================================================================
// Objects
// ====================================================================

module lamp_shade() {
    if (1) up(shade_height)
        see_through("yellow")
        shade_cap();

    intersection() {
        solid("red")
            shade_struts();
        lamp_body();
    }

    offset_scale = (shade_size - wall_thickness + 2 * epsilon) / shade_size;
    tube_height = 4 * lug_size + wall_thickness;
    tube_radius = base_size / 2;

    if (1)
    solid("green")
    down(transition_height + 4 * wall_thickness - epsilon)
    difference() {
        cyl(h = tube_height, r = tube_radius);
        down(epsilon)
            cyl(h = tube_height + 3 * epsilon,
                r = tube_radius - 2 * wall_thickness);
    }

    transition_height = (shade_size - base_size) / 2;
    if (1)
    solid("olive")
    difference() {
        hull() {
            up(tolerance)
            cuboid([
                shade_size + lamp_corner_radius,
                shade_size + lamp_corner_radius,
                tolerance],
                rounding = lamp_corner_radius, edges="Z", anchor = TOP);
            down(transition_height)
            cyl(h = tolerance,
                r = tube_radius, anchor = BOTTOM);
        }
        up(wall_thickness)
            cyl(h = transition_height + 6 * wall_thickness,
                r = tube_radius - 2 * wall_thickness,
                anchor = TOP);
    }

    difference() {
        see_through("blue")
            lamp_body();
        up(wall_thickness - epsilon) scale([offset_scale, offset_scale, offset_scale] )
            lamp_body();
        down(wall_thickness)
            cyl(h = 4 * wall_thickness, r = tube_radius);
    }

}


// ====================================================================
// Main Assembly & Plates
// ====================================================================
if ($preview || local) { // main assembly in Parametric Model Maker
    lamp_shade();
}

module mw_plate_1() {
    lamp_shade();
}
