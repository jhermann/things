/*  Lamp shade: round with diamond pattern

    TODO:
    - Top cap with inset image, in white
    - Top cap with same texture as base
*/include <BOSL2/std.scad>

/* [Lamp Shade Dimensions] */
// Outer diameter (common: 102, 130)
outer_diameter = 102; // [100:1:150]
// Height of the shade
total_height = 160; // [10:1:40]
// Wall thickness of the lamp shade
wall_thickness = 1; // [0.5:0.25:3]
// Chamfer applied to top and bottom edges
wall_chamfer = .3; // [0.2:0.1:2]
// Texture selection index (see description)
texture_id = 0; // [0:1:10]
// Print upright?
upright = false;
// Print without a cap?
topless = true;

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

// rotational extrusion of an ellipsoid with its center at `radius`
module torus(radius, rx, ry, arc=360) {
    rotate_extrude(angle=arc, convexity=2)
        translate([radius, 0, 0])
            scale([rx, ry, 1])
                circle(r=1, $fn=$fn);
}

// the top plate (placed on the print bed)
module shade_top(tex, tex_param, with_top=!topless, orientation=upright) {
    if (with_top) {
        color("orange")
        // Top face
        cyl(h = top_height,
            r = outer_diameter / 2,
            anchor=TOP, chamfer = wall_chamfer)
                // Attach to the bottom face
                attach(upright ? TOP : BOTTOM, BOTTOM, overlap=-epsilon)
                intersection() {
                    // The pattern
                    textured_tile(tex,
                        size=[outer_diameter, outer_diameter],
                        tex_size = tex_param[2],
                        tex_depth = tex_param[3],
                    );

                    // Clip to the top face shape
                    cyl(h = 2 * tex_param[3], r = outer_diameter / 2 - (upright || !with_top ? 2 : 1) * wall_chamfer, chamfer = orientation ? -wall_chamfer : wall_chamfer, anchor=TOP);
                }
    }
}

// the bottom plate and connecting hole
module shade_bottom() {
    connector_ring_radius = connector_outer_diameter / 2 + 1.9 * tolerance;
    strut_size = (outer_diameter - connector_outer_diameter) / 2;

    difference() {
        // Connector ring
        union() {
            if (1) color("red")
            down(upright ? connector_height / 2 - wall_thickness : 2 * wall_thickness)
            cyl(h = connector_height / 2,
                r = connector_ring_radius + 2 * wall_thickness,
                anchor=BOTTOM, chamfer = 2 * wall_chamfer);

            // Upside-down print strut, with inner walls
            difference() {
                color("yellow")
                up(wall_chamfer)
                rotate_extrude(convexity=2)
                    left(outer_diameter / 2 - wall_thickness + epsilon)
                    polygon(points=[
                        [0, 0],
                        [strut_size, 0],
                        [0, strut_size]
                   ]);

                // Force inner wall creation
                for (offset = [.15, .4, .65])
                    torus(radius=outer_diameter / 2 - wall_thickness - offset * strut_size,
                          rx=tolerance, ry=(1 - offset) * strut_size - tolerance);
            }

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


// ====================================================================
// Objects
// ====================================================================

module lamp_shade(tex_param = tex_config[texture_id]) {
    tex = tex_param[1] ? texture(tex_param[0], border=tex_param[1]) : texture(tex_param[0]);

    up(total_height) shade_top(tex, tex_param);
    shade_bottom();

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
        mw_plate_1();
    }
}

// Plate 1: Shade Body
module mw_plate_1() {
    gap = topless ? top_height : 0;

    if (upright) {
        up(connector_height / 2 - wall_thickness)
        lamp_shade();
    } else {
        up(total_height - gap) xrot(180)
        lamp_shade();
    }
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
        shade_top(tex, tex_param, orientation=true);

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
