/*  Lamp shade: round wall as wide as the base,
    with selectable texture and integrated connector

    TODO:
    - Top cap with inset image, in white
    - Top cap with same texture as base
*/
include <BOSL2/std.scad>

/* [Lamp Shade Dimensions] */
// Height of the shade
total_height = 160; // [10:1:40]
// Wall thickness of the lamp shade
wall_thickness = 1.5; // [0.5:0.25:3]
// Texture selection index (see description)
texture_id = 4; // [0:1:10]

/* [Connector Dimensions] */
// Outer diameter of the connector
connector_outer_diameter = 97; // [50:.5:150]
// Height of the connector on each side
connector_height = 11; // [10:1:40]

/* [Hidden] */
//$preview = true;
local = 0;
texture_preview = 0;
$fa = $preview ? 16 : 1;
$fs = $preview ? 2 : 0.1;

// Compliance tolerance for parts fitting
tolerance = 0.2;
// Extra gap added to carve-out shapes
epsilon = 0.05;
// Layer height
layer_height = .2;

outer_diameter = connector_outer_diameter + 2 * (wall_thickness + tolerance);
wall_chamfer = wall_thickness - layer_height;
top_height = 1.25 * wall_thickness;
plug_radius = connector_outer_diameter / 2 - tolerance;

// name, border, size, depth
tex_config = [
    ["hex_grid", .1, [15, 20], .3], // 0
    ["tri_grid", .08, [15, 25], .4], // 1
    ["trunc_pyramids_vnf", .2, [15, 15], .4], // 2
    ["trunc_diamonds", .16, [15, 25], .4], // 3
    ["hills", 0, [10, 10], .45], // 4
    ["rough", 0, [30, 70], .25], // 5
    ["dots", .25, [7, 7], .3], // 6
    ["cubes", 0, [10, 10], .45], // 7
    ["cones", .15, [7, 7], .4], // 8
    ["checkers", .1, [15, 15], .25], // 9
    ["bricks_vnf", .15, [15, 15], .25], // 10
];


// ====================================================================
// Parts
// ====================================================================

// the top plate (placed on the print bed)
module shade_top(tex, tex_param) {
    color("orange")
    // Top face
    cyl(h = top_height,
        r = outer_diameter / 2,
        anchor=TOP, chamfer = wall_chamfer)
            // Attach to the bottom face
            attach(TOP, BOTTOM, overlap=-epsilon)
            intersection() {
                // The pattern
                textured_tile(tex,
                    size=[outer_diameter, outer_diameter],
                    tex_size = tex_param[2],
                    tex_depth = tex_param[3],
                );

                // Clip to the top face shape
                cyl(h = 2 * tex_param[3],
                    r = outer_diameter / 2 - 2 * wall_chamfer,
                    chamfer=-wall_chamfer, anchor=TOP);
            }
}

// Friction dots for the cap
module cap_dots() {
    dot_size = top_height - wall_chamfer - tolerance;
    dot_shift = plug_radius - tolerance;

    echo("DOT diameter:", 2 * dot_shift + wall_thickness);

    for (angle = [45: 90: 360]) {
        color("red")
        zrot(angle) up(dot_size / 2 + tolerance / 2) right(dot_shift)
        spheroid(d=[dot_size, wall_thickness, dot_size], anchor=BOTTOM);
    }
}

// Tongue slots for better friction fit
module tongue_slots() {
    side = 2 * (connector_height - 1.5 * wall_thickness) / sqrt(3);
    for(angle = [0 : 90 : 360]) {
        zrot(angle)
            fwd(connector_outer_diameter / 2 - wall_thickness) xrot(90)
                linear_extrude(height = 4 * wall_thickness, center = true)
                    polygon([
                        [-side/2, 0],
                        [side/2, 0],
                        [tolerance, connector_height - 1.5 * wall_thickness],
                        [-tolerance, connector_height - 1.5 * wall_thickness]
                    ]);
    }
}

// Elliptical bumps to increase compliance, placed on the outside of the tongues
module friction_dots() {
    dot_scale = .2;
    for(angle = [0 : 90 : 360]) {
        up(dot_scale * connector_height + 1.75 * wall_chamfer)
        zrot(angle) fwd(connector_outer_diameter / 2)
            spheroid([dot_scale * connector_height, wall_thickness / 2, dot_scale * connector_height]);
    }
}

module lamp_connector() {
    chamfer = wall_thickness / 6;

    difference() {
        // The main tube of the connector, with chamfered inner and outer edges
        cyl(h = connector_height + tolerance,
            r = connector_outer_diameter / 2,
            anchor=BOTTOM, chamfer = chamfer);

        down(epsilon)
        cyl(h = connector_height + tolerance + 2 * epsilon,
            r = connector_outer_diameter / 2 - wall_thickness,
            anchor=BOTTOM, chamfer = -chamfer);

        // Triangular cuts at +/- 12 degrees, to form the friction fit tongues;
        // the lower ones are raised slightly to ensure a uniform 1st layer for good bed adhesion
        up(2 * layer_height) zrot(-12) tongue_slots();
        up(2 * layer_height) zrot(12) tongue_slots();
    }
    friction_dots();

    // Triangular ring, chamfered almost to the inner shade wall perimeter;
    // the upper part fuses the conenctor to the wall (they overlap), the
    // lower part serves as a support for printing the wall on (no overhang).
    up(connector_height + tolerance - epsilon)
    difference() {
        // Cylinder with triangular outer rim
        cyl(h = 2 * wall_thickness + epsilon,
            r = outer_diameter / 2,
            anchor=BOTTOM, chamfer = wall_thickness - epsilon);

        // Hole compatible to the shade tube
        down(wall_thickness)
        cyl(h = 4 * wall_thickness,
            r = connector_outer_diameter / 2 - wall_thickness,
            anchor=BOTTOM);
    }
}

// ====================================================================
// Objects
// ====================================================================

module lamp_shade(tex_param = tex_config[texture_id]) {
    tex = tex_param[1] ? texture(tex_param[0], border=tex_param[1]) : texture(tex_param[0]);

    // Main tube with texture
    if (1)
    difference() {
        // Main wall
        union() {
            color("navy")
            cyl(h = wall_thickness + epsilon,
                r = outer_diameter / 2,
                anchor = BOTTOM);

            color("blue", alpha=.6)
            up(wall_thickness)
            cyl(h = total_height - 2 * wall_thickness,
                r = outer_diameter / 2,
                texture = tex,
                tex_size = tex_param[2],
                tex_depth = tex_param[3],
                tex_inset = true,
                anchor = BOTTOM);

            color("navy")
            up(total_height)
            cyl(h = wall_thickness + epsilon,
                r = outer_diameter / 2,
                anchor = TOP);
        }

        // Empty space
        chamfer_gain = wall_chamfer - .4;
        down(chamfer_gain + epsilon)
        cyl(h = total_height + chamfer_gain + 2 * epsilon,
            r = outer_diameter / 2 - wall_thickness,
            chamfer=-wall_chamfer,
            anchor=BOTTOM);
    }
}


// ====================================================================
// Main Assembly & Plates
// ====================================================================
if ($preview || local) { // main assembly in Parametric Model Maker
    if (texture_preview) {
        rows = 3;
        grid_copies(spacing=[1.25 * outer_diameter, 1.75 * outer_diameter], n=[ceil(len(tex_config) / rows), rows])
            if ($idx < len(tex_config))
                lamp_shade(tex_param = tex_config[$idx]);
    } else {
        mw_plate_1();
    }
}

// Plate 1: Shade Body
module mw_plate_1() {
    if (1) up(connector_height + tolerance + wall_thickness - epsilon)
        lamp_shade();
    lamp_connector();
}

// Plate 2: Textured Cap
module mw_plate_2() {
    tex_param = tex_config[texture_id];
    tex = tex_param[1] ? texture(tex_param[0], border=tex_param[1]) : texture(tex_param[0]);

    echo("OUTER diameter:", outer_diameter);
    echo("PLUG diameter:", 2 * plug_radius);
    strut_height = outer_diameter / 2 - plug_radius;

    up(top_height) xrot(180) {
        up(wall_chamfer)
        shade_top(tex, tex_param);

        if (1) color("red")
        cyl(h = strut_height + wall_chamfer,
            r1 = outer_diameter / 2,
            r2 = plug_radius,
            anchor=BOTTOM); //, chamfer = -strut_height);

        if (1)
        up(strut_height) {
            cap_dots();
            color("yellow")
            cyl(h = top_height + wall_chamfer,
                r = plug_radius,
                anchor=BOTTOM, chamfer = wall_chamfer);
        }
    }
}

// Plate 3: Cap with SVG Image (TODO)
module mw_plate_3() {
     up(top_height) {
        cap_dots();

        color("orange")
        cyl(h = top_height,
            r = outer_diameter / 2,
            anchor=TOP, chamfer = wall_chamfer);

        down(wall_chamfer)
        difference() {
            color("yellow")
            cyl(h = top_height + wall_chamfer,
                r = outer_diameter / 2 - wall_thickness - tolerance,
                anchor=BOTTOM, chamfer = wall_chamfer);
            cyl(h = top_height + wall_chamfer + epsilon,
                r = outer_diameter / 2 - 2 * wall_thickness - tolerance,
                anchor=BOTTOM, chamfer = -wall_chamfer);
        }
    }
}
