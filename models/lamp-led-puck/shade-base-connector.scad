// Lamp shade and base friction-fit connector
// Print in PETG due to mechanical stress for better durability.
//
// H: 2*11.2mm + ring; D: 98mm (97mm); friction ring: 11.2 - 2 * 4.7 = 1.8mm
// OUTER base diameter: 102.8 - 2 * 1.25 = 100.3 - 2 * .2 = 99.9
include <BOSL2/std.scad>

/* [Connector Dimensions] */
// Outer diameter of the connector
connector_outer_diameter = 98; // [50:1:150]
// Height of the connector on each side
connector_height = 11; // [10:1:40]
// Wall thickness of the lamp base and shade
wall_thickness = 1.25; // [0.5:0.25:3]
// Chamfer applied to top and bottom edges
wall_chamfer = .25; // [0.5:0.25:2]

/* [Hidden] */
//$preview = true;
local = 0;
$fa = $preview ? 16 : 1;
$fs = $preview ? 2 : 0.1;

// Compliance tolerance for parts fitting
tolerance = 0.2;
// Extra gap added to carve-out shapes
epsilon = 0.05;

layer_height = .2;
total_height = 2 * connector_height + wall_thickness;


// ====================================================================
// Parts
// ====================================================================

// Rotational extrusion of an ellipsoid with its center at `radius`
module torus(radius, rx, ry, arc=360) {
    rotate_extrude(angle=arc, convexity=2)
        translate([radius, 0, 0])
            scale([rx, ry, 1])
                circle(r=1, $fn=$fn);
}

// Tongue slots for better friction fit
module tongue_slots() {
    side = 2 * (connector_height - wall_thickness) / sqrt(3);
    for(angle = [0 : 90 : 360]) {
        zrot(angle)
            fwd(connector_outer_diameter / 2 - wall_thickness) xrot(90)
                linear_extrude(height = 4 * wall_thickness, center = true)
                    polygon([
                        [-side/2, 0],
                        [side/2, 0],
                        [tolerance, connector_height - wall_thickness],
                        [-tolerance, connector_height - wall_thickness]
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

// ====================================================================
// Objects
// ====================================================================

module lamp_connector() {
    // Torus protruding partially from the outside wall, between the lower and upper part
    color("red")
    up(connector_height + wall_thickness / 2)
    torus(radius=(connector_outer_diameter - wall_thickness) / 2, rx=wall_thickness, ry=wall_thickness);

    difference() {
        // The main tube of the connector, with chamfered inner and outer edges
        cyl(h = total_height, r = connector_outer_diameter / 2, anchor=BOTTOM, chamfer = wall_chamfer);
        down(epsilon)
        cyl(h = total_height + 2 * epsilon,
            r = connector_outer_diameter / 2 - wall_thickness,
            anchor=BOTTOM, chamfer = -wall_chamfer);

        // Triangular cuts at +/- 10 degrees, to form the friction fit tongues;
        // the lower ones are raised slightly to ensure a uniform 1st layer for good bed adhesion
        up(2 * layer_height) zrot(-10) tongue_slots();
        up(2 * layer_height) zrot(10) tongue_slots();
        up(total_height + epsilon) zrot(35) xrot(180) tongue_slots();
        up(total_height + epsilon) zrot(55) xrot(180) tongue_slots();
    }

    // Lower & upper friction dots
    friction_dots();
    up(total_height + epsilon) zrot(45) xrot(180) friction_dots();
}


// ====================================================================
// Main Assembly & Plates
// ====================================================================
if ($preview || local) { // main assembly in Parametric Model Maker & local preview
    lamp_connector();
}

// Plate 1 on MakerWorld (via magic naming)
module mw_plate_1() {
    lamp_connector();
}
