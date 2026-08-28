// ====================================================================
// Parametric AC Hose Bayonet Connector / Adapter (Female)
// ====================================================================

//$preview = true; // Override in VS Code

/* [Hose Connector] */
hose_diameter           = 150;   // Nominal outer diameter of the hose (mm)
hose_connector_height   = 45;    // Height of straight cylindrical section (mm)
wall_thickness          = 2.5;   // Wall thickness for connector & top rim (mm)
tolerance_gap           = 0.15;  // Subtracted from outer diameter for fit (mm)

/* [Connector Slots] */
locking_lug_length      = 20;    // Circumferential arc length of each lug (mm)
locking_lug_size        = 7.5;   // Square radial and vertical cross-section (mm)

// Fast preview, smooth final curves
$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.1;

// ====================================================================
// Animation
// ====================================================================
anim_scene1 = (.25 < $t && $t <= .5) ? sin(360 * 4 * ($t - .25)) : 0;
anim_scene2 = (.5 < $t && $t <= .75) ? sin(360 * 2 * ($t - .5)) : 0;
anim_scene3 = (.75 < $t) ? sin(360 * 2 * ($t - .75)) : 0;
_hose_diameter = hose_diameter * (1 + .25 * anim_scene2);
_hose_connector_height = hose_connector_height * (1 + .5 * anim_scene3);

// ====================================================================
// Derived Dimensions
// ====================================================================
outer_radius = (_hose_diameter / 2) - tolerance_gap;
inner_radius = outer_radius - wall_thickness;
edge_pad     = 0.25; // Padding to guarantee clean CSG subtractions
slot_cover   = 2 * wall_thickness; // retaining "roof" of the slot
transition_height = 2 * locking_lug_size;
// Set ring_wall_thickness to 0 to expose bayonet slots
ring_wall_thickness = 1 * wall_thickness;
ring_height          = 2 * locking_lug_size + 4 * wall_thickness;
ring_outer_radius    = _hose_diameter / 2 + locking_lug_size;
ring_inner_radius    = outer_radius + 1.5 * tolerance_gap;
ring_chamfer         = wall_thickness / 4;
slot_outer_radius    = ring_inner_radius + locking_lug_size;
lug_center_radius    = (ring_inner_radius + slot_outer_radius) / 2;
slot_depth           = 2 * locking_lug_size + slot_cover;
indicator_lug_angle  = 1.1 * (locking_lug_length + tolerance_gap + 2 * edge_pad)
    / (outer_radius + 1.5 * tolerance_gap + locking_lug_size / 2) * 180 / PI;
indicator_zoom       = 1.5;

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
// Main Assembly & Plates
// ====================================================================
if ($preview) main_assembly();

module main_assembly() {
    rotate([0, 180, 45])
        mw_plate_2();

    translate([0, 0, 1 * ring_height])
        mw_plate_3();
}

module mw_plate_1() {
    female_connector([45 * anim_scene1, 30 * anim_scene1, $t <= .25 ? $t * 360 : 0]);
}

module mw_plate_2() {
    male_connector([0, 0, 0]);
}

module mw_plate_3() {
    female_connector([0, 0, 0], tube_extension=true);
}

// ====================================================================
// Female Connector
// ====================================================================
module female_connector(view_angle, tube_extension=false) {
    slim_height = tube_extension ? (5 * wall_thickness) : _hose_connector_height;
    extension_height = _hose_connector_height - transition_height - slim_height;
    top_ring_radius = tube_extension ? (outer_radius + tolerance_gap) : inner_radius;

    rotate(view_angle)
    union() {
        // Main Hose Connector Cylinder
        difference() {
            // Main tube body
            cylinder(r = outer_radius, h = slim_height + 2 * locking_lug_size);

            // Main hole (top to bottom)
            translate([0, 0, -edge_pad])
                cylinder(r = inner_radius, h = _hose_connector_height + 2 * locking_lug_size + 2 * edge_pad);

            // Male adapter receiving space (room for its wall)
            translate([0, 0, -edge_pad])
                cylinder(r = _hose_diameter / 2 + edge_pad, h = 2 * locking_lug_size + slot_cover + 2 * edge_pad);

            // Connect tube and ring via a chamfer (so the inner tube needs no supports)
            rotate_extrude()
                polygon([
                    [inner_radius - edge_pad, 2 * locking_lug_size + slot_cover + wall_thickness],
                    [inner_radius - edge_pad, 2 * locking_lug_size + slot_cover],
                    [outer_radius + edge_pad, 2 * locking_lug_size + slot_cover]
                ]);
        }

        // Fill a gap between ring and tube wall / tube chamfer
        rotate_extrude()
            polygon([
                [outer_radius + 2 * tolerance_gap, 2 * locking_lug_size + slot_cover + edge_pad],
                [outer_radius - edge_pad, 2 * locking_lug_size + slot_cover + edge_pad],
                [outer_radius - edge_pad, 2 * locking_lug_size + slot_cover + wall_thickness],
                [outer_radius + 2 * tolerance_gap, 2 * locking_lug_size + slot_cover + wall_thickness]
            ]);

        // Continuous base ring around the outside of the tube, with locking slots
        female_outside_ring();
        female_twist_indicators();

        if (tube_extension) {
            // Add slanted slim/wide tube connect
            translate([0, 0, slim_height + 2 * locking_lug_size])
                female_tube_transition(inner_radius, outer_radius + tolerance_gap, transition_height, wall_thickness);

            // Add wider tube
            translate([0, 0, slim_height + 2 * locking_lug_size + transition_height])
                difference() {
                    cylinder(r = outer_radius + wall_thickness + tolerance_gap, h = extension_height);
                    translate([0, 0, -locking_lug_size])
                        cylinder(r = outer_radius + tolerance_gap, h = extension_height + 2 * locking_lug_size);
                }
        }

        // Convex Quarter-Circle Lead-in Rim (Points Upward & Outward)
        translate([0, 0, _hose_connector_height + 2 * locking_lug_size])
            female_top_lead_in_rim(top_ring_radius);
    }
}

// ====================================================================
// For the adapter geometry, this connects the ring with the wider tube
module female_tube_transition(r1, r2, height, thickness) {
    // Extrude a slanted rectangle going from r1 to r2
    rotate_extrude() {
        polygon(points=[
            [r1, 0],
            [r2, height],
            [r2 + thickness, height],
            [r1 + thickness, 0]
        ]);
    }
}

// ====================================================================
// Convex Lead-In Rim
// Profile: A solid 90° quarter-circle arc centered at (inner_radius, 0),
// sweeping UPWARD and OUTWARD towards outer_radius.
module female_top_lead_in_rim(radius) {
    rotate_extrude() {
        translate([radius, 0, 0]) {
            intersection() {
                // Quarter circle bulging outward and upward
                circle(r = wall_thickness, $fn = $fn);

                // Keep only top-right quadrant (X >= 0, Y >= 0)
                square([wall_thickness, wall_thickness]);
            }
        }
    }
}

// ====================================================================
// The ring at the bottom holding the bayonet slots
module female_outside_ring() {
    top_chamfer_size = ring_outer_radius - ring_inner_radius + ring_wall_thickness;

    // The ring body
    difference() {
        // The ring body, inner cylinders get subtracted later to make it hollow
        cylinder(r = ring_outer_radius + ring_wall_thickness, h = ring_height);

        // Outer bottom ring chamfer (print bed)
        rotate_extrude()
            polygon([
                [ring_outer_radius + ring_wall_thickness - ring_chamfer, 0],
                [ring_outer_radius + ring_wall_thickness + edge_pad, 0],
                [ring_outer_radius + ring_wall_thickness + edge_pad, ring_chamfer + edge_pad]
            ]);

        // Inner bottom ring chamfer (print bed)
        rotate_extrude()
            polygon([
                [ring_inner_radius + .33 * wall_thickness, -edge_pad],
                [ring_inner_radius - edge_pad, -edge_pad],
                [ring_inner_radius - edge_pad, .5 * wall_thickness]
            ]);

        // Cut out the slots
        female_bayonet_slots();

        translate([0, 0, -edge_pad])
            cylinder(r = outer_radius + 1.75 * tolerance_gap, h = ring_height + 2 * edge_pad);
    }

    // Top ring chamfer
    rotate_extrude()
        polygon([
            [inner_radius + tolerance_gap, ring_height - edge_pad],
            [ring_inner_radius + top_chamfer_size, ring_height - edge_pad],
            [inner_radius + tolerance_gap, ring_height + .5 * top_chamfer_size]
        ]);
}

// ====================================================================
// Symbols to indicate open/close direction for twisting
module female_twist_indicators() {
    // Open / close indicators near each slot
    for (slot_center = [45 : 90 : 315]) {
        // Open (torus)
        rotate([0, 0, slot_center - indicator_lug_angle]) {
            translate([ring_outer_radius + .85 * ring_wall_thickness, 0, 1.5 * locking_lug_size])
                rotate([0, 90,  0]) scale([indicator_zoom, indicator_zoom, 1]) scale(ring_wall_thickness)
                    torus(1.65, .4, .4);
        }

        // Left / right arrows
        rotate([0, 0, slot_center]) {
            translate([ring_outer_radius + .85 * ring_wall_thickness, 0, 1.5 * locking_lug_size])
                scale([.75, indicator_zoom * 6, indicator_zoom * 2])
                    rotate([0, 90, 0]) {
                        linear_extrude(height = ring_wall_thickness, center = true)
                            polygon([
                                [-ring_wall_thickness, ring_wall_thickness * .125],
                                [0, ring_wall_thickness / 2],
                                [ring_wall_thickness, ring_wall_thickness * .125]
                            ]);
                        linear_extrude(height = ring_wall_thickness, center = true)
                            polygon([
                                [-ring_wall_thickness, -ring_wall_thickness * .125],
                                [0, -ring_wall_thickness / 2],
                                [ring_wall_thickness, -ring_wall_thickness * .125]
                            ]);
                    }
        }

        // Close (filled circle)
        rotate([0, 0, slot_center + indicator_lug_angle]) {
            translate([ring_outer_radius + .85 * ring_wall_thickness, 0, 1.5 * locking_lug_size])
                scale([.65, indicator_zoom * 2, indicator_zoom * 2])
                    sphere(r = ring_wall_thickness, $fn = $fn);
        }
    }
}

// ====================================================================
// Positive model of the L-shaped slots; gets carved out in the
// female_outside_ring() module
module female_bayonet_slots() {
    lug_angle = (locking_lug_length + tolerance_gap + 2 * edge_pad) / lug_center_radius * 180 / PI;
    lug_angle_padded = (1.125 * locking_lug_length + tolerance_gap) / lug_center_radius * 180 / PI;
    channel_angle = 3 * lug_angle_padded;

    // Create 4 slots
    for (slot_center = [45 : 90 : 315]) {
        rotate([0, 0, slot_center - lug_angle / 2]) {
            // Lug entry port, open to the bottom
            rotate_extrude(angle = lug_angle_padded, convexity = 2)
                polygon([
                    [ring_inner_radius - edge_pad, -edge_pad],
                    [slot_outer_radius, -edge_pad],
                    [slot_outer_radius, slot_depth - locking_lug_size + edge_pad],
                    [ring_inner_radius - edge_pad, slot_depth - locking_lug_size + edge_pad]
                ]);
        }

        // Locking lug space (lowers bottom of the space to catch the lug)
        rotate([0, 0, slot_center - .5 * lug_angle]) {
            // Lowered bottom triangle
            translate([0, 0, slot_cover - .7 * wall_thickness])
                rotate_extrude(angle = channel_angle, convexity = 2)
                    polygon([
                        [ring_inner_radius - edge_pad, -edge_pad],
                        [slot_outer_radius + edge_pad, locking_lug_size + edge_pad],
                        [ring_inner_radius - edge_pad, locking_lug_size + edge_pad]
                    ]);

            // Rect space to meet the lowered bottom triangle
            translate([0, 0, slot_cover + locking_lug_size - .7 * wall_thickness])
                rotate_extrude(angle = channel_angle, convexity = 2)
                    polygon([
                        [ring_inner_radius - edge_pad, .7 * wall_thickness],
                        [slot_outer_radius + edge_pad, .7 * wall_thickness],
                        [slot_outer_radius + edge_pad, 0],
                        [ring_inner_radius - edge_pad, 0],
                    ]);

            // Upper triangle
            rotate_extrude(angle = channel_angle, convexity = 2)
                polygon([
                    [ring_inner_radius - edge_pad, locking_lug_size + slot_cover - edge_pad],
                    [slot_outer_radius + edge_pad, locking_lug_size + slot_cover - edge_pad],
                    [ring_inner_radius - edge_pad, slot_depth + edge_pad]
                ]);
        }
    }
}

// ====================================================================
// Male Connector
// ====================================================================
module male_connector(view_angle) {
    rotate(view_angle)
    union() {
        bevel_size = wall_thickness;

        // Main Hose Connector Cylinder
        difference() {
            cylinder(r = outer_radius, h = hose_connector_height);
            translate([0, 0, -edge_pad])
                cylinder(r = inner_radius, h = hose_connector_height + 2 * edge_pad);
        }

        // Convex Quarter-Circle Lead-in Rim (Points Upward & Outward)
        translate([0, 0, hose_connector_height])
            male_top_lead_in_rim();

        // Bevel to mark max. hose insertion
        translate([0, 0, 2 * (locking_lug_size + bevel_size)])
            rotate_extrude()
                translate([outer_radius - wall_thickness / 3, 0, 0])
                    scale([.66, 1, 1])
                        circle(r = wall_thickness, $fn = $fn);

        // Square-section ring cut into four arced locking lugs, resting on the print plate
        male_locking_lugs();
    }
}

// Convex Lead-In Rim
// Profile: A solid 90° quarter-circle arc centered at (inner_radius, 0),
// sweeping UPWARD and OUTWARD towards outer_radius.
module male_top_lead_in_rim() {
    rotate_extrude() {
        translate([inner_radius, 0, 0]) {
            intersection() {
                // Quarter circle bulging outward and upward
                circle(r = wall_thickness, $fn = $fn);

                // Keep only top-right quadrant (X >= 0, Y >= 0)
                square([wall_thickness, wall_thickness]);
            }
        }
    }
}

// Square-section ring with four gaps sized to leave the requested lug arc length
module male_locking_lugs() {
    ring_inner_radius = outer_radius;
    ring_outer_radius = ring_inner_radius + locking_lug_size;
    ring_height = locking_lug_size * 2;
    lug_center_radius = (ring_inner_radius + ring_outer_radius) / 2;
    lug_angle = locking_lug_length / lug_center_radius * 180 / PI;
    gap_angle = 90 - lug_angle;
    hole_count = 0; // floor(locking_lug_length / (3 * wall_thickness));
    hole_spacing = 3 * wall_thickness;
    hole_margin = (locking_lug_length - (hole_count * wall_thickness + (hole_count - 1) * 2 * wall_thickness)) / 2;

    difference() {
        rotate_extrude(convexity = 2)
            polygon([
                [ring_inner_radius, 0],
                [ring_outer_radius, locking_lug_size],
                [ring_inner_radius, ring_height]
            ]);

        if (hole_count > 0)
            for (lug_center = [0 : 90 : 270])
                for (hole_index = [0 : hole_count - 1]) {
                    hole_arc_position = hole_margin + wall_thickness / 2 + hole_index * hole_spacing;
                    hole_angle = lug_center - lug_angle / 2 + hole_arc_position / locking_lug_length * lug_angle;
                    rotate([0, 0, hole_angle])
                        translate([lug_center_radius, 0, locking_lug_size / 2])
                            rotate([0, 90, 0])
                                cylinder(
                                    r = wall_thickness / 2,
                                    h = locking_lug_size + 2 * edge_pad,
                                    center = true,
                                    $fn = 6
                                );
                }

        for (gap_center = [45 : 90 : 315])
            rotate([0, 0, gap_center - gap_angle / 2])
                rotate_extrude(angle = gap_angle, convexity = 2)
                    polygon([
                        [ring_inner_radius - edge_pad, -edge_pad],
                        [ring_outer_radius + edge_pad, -edge_pad],
                        [ring_outer_radius + edge_pad, ring_height + edge_pad],
                        [ring_inner_radius - edge_pad, ring_height + edge_pad]
                    ]);
    }
}
