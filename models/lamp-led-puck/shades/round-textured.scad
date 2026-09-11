// Lamp shade: round with diamond pattern
//
// Connector H: 11.2mm
include <BOSL2/std.scad>

/* [Lamp Shade Dimensions] */
// Outer diameter
outer_diameter = 130; // [100:1:150]
// Height of the shade
total_height = 160; // [10:1:40]
// Wall thickness of the lamp shade
wall_thickness = 1; // [0.5:0.25:3]
// Chamfer applied to top and bottom edges
wall_chamfer = .3; // [0.2:0.1:2]

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

// name, border, size, depth
tex_id = 0;
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

// rotational extrusion of an ellipsoid with its center at `radius`
module torus(radius, rx, ry, arc=360) {
    rotate_extrude(angle=arc, convexity=2)
        translate([radius, 0, 0])
            scale([rx, ry, 1])
                circle(r=1, $fn=$fn);
}

// ====================================================================
// Objects
// ====================================================================

module lamp_shade(tex_param = tex_config[tex_id]) {
    tex = tex_param[1] ? texture(tex_param[0], border=tex_param[1]) : texture(tex_param[0]);
    connector_ring_radius = connector_outer_diameter / 2 + 1.9 * tolerance;
    strut_size = (outer_diameter - connector_outer_diameter) / 2;

    // Top face
    if (1) color("orange") up(total_height)
    cyl(h = 2 * wall_thickness,
        r = outer_diameter / 2,
        anchor=TOP, chamfer = wall_chamfer);

    difference() {
        // Connector ring
        union() {
            if (1) color("red")
            down(2 * wall_thickness)
            cyl(h = connector_height / 2,
                r = connector_ring_radius + 2 * wall_thickness,
                anchor=BOTTOM, chamfer = 2 * wall_chamfer);

            // Upside-down print strut
            color("yellow")
            up(wall_chamfer)
            rotate_extrude(convexity=2)
                left(outer_diameter / 2 - wall_thickness + epsilon)
                polygon(points=[
                    [0, 0],
                    [strut_size, 0],
                    [0, strut_size]
                ]);

            // Bottom face
            color("orange")
            cyl(h = 2 * wall_thickness,
                r = outer_diameter / 2,
                anchor=BOTTOM, chamfer = wall_chamfer);
        }

        // Bottom hole
        cyl(h = 4 * connector_height,
            r = connector_ring_radius,
            anchor=CENTER,);
    }

    // Main tube with texture
    if (1) up(2 * wall_thickness - wall_chamfer)
    difference() {
        // Main wall
        color("blue", alpha=1)
        cyl(h = total_height - 4 * wall_thickness + 2 * wall_chamfer,
            r = outer_diameter / 2,
            texture = tex,
            tex_size = tex_param[2],
            tex_depth = tex_param[3],
            tex_inset = true,
            anchor = BOTTOM);

        // Empty space
        down(epsilon)
        cyl(h = total_height + 2 * epsilon,
            r = outer_diameter / 2 - 2 * wall_thickness,
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
        up(total_height) xrot(180)
        lamp_shade();
    }
}

module mw_plate_1() {
    up(total_height) xrot(180) lamp_shade();
}
