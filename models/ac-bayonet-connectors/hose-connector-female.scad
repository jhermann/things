    // ====================================================================
    // Parametric AC Hose Bayonet Connector / Adapter (Female)
    // ====================================================================

    /* [Hose Connector] */
    hose_diameter           = 150;   // Nominal outer diameter of the hose (mm)
    hose_connector_height   = 45;    // Height of straight cylindrical section (mm)
    wall_thickness          = 2.5;   // Wall thickness for connector & top rim (mm)
    tolerance_gap           = 0.15;  // Subtracted from outer diameter for fit (mm)
    tube_extension          = false; // Should this extend an existing tube?

    /* [Connector Slots] */
    locking_lug_length      = 20;    // Circumferential arc length of each lug (mm)
    locking_lug_size        = 7.5;   // Square radial and vertical cross-section (mm)

    /* [Quality] */
    $fn = 120;                       // Circle resolution parameter

    // ====================================================================
    // Derived Dimensions
    // ====================================================================
    outer_radius = (hose_diameter / 2) - tolerance_gap;
    inner_radius = outer_radius - wall_thickness;
    edge_pad     = 0.25; // Padding to guarantee clean CSG subtractions
    slot_cover   = 2 * wall_thickness; // retaining "roof" of the slot
    slim_height  = tube_extension ? (5 * wall_thickness) : hose_connector_height;
    transition_height = 2 * locking_lug_size;
    extension_height  = hose_connector_height - transition_height - slim_height;
    top_ring_radius   = tube_extension ? (outer_radius + tolerance_gap) : inner_radius;
    // Set ring_wall_thickness to 0 to expose bayonet slots
    ring_wall_thickness = 1 * wall_thickness;
    ring_height          = 2 * locking_lug_size + 4 * wall_thickness;
    ring_outer_radius    = hose_diameter / 2 + locking_lug_size;
    ring_inner_radius    = outer_radius + 1.5 * tolerance_gap;
    ring_chamfer         = wall_thickness / 4;
    slot_outer_radius    = ring_inner_radius + locking_lug_size;
    lug_center_radius    = (ring_inner_radius + slot_outer_radius) / 2;
    slot_depth           = 2 * locking_lug_size + slot_cover;
    indicator_lug_angle  = (locking_lug_length + tolerance_gap + 2 * edge_pad)
        / (outer_radius + 1.5 * tolerance_gap + locking_lug_size / 2) * 180 / PI;

    // ====================================================================
    // Main Assembly
    // ====================================================================
    union() {
        // Main Hose Connector Cylinder
        difference() {
            // Main tube body
            cylinder(r = outer_radius, h = slim_height + 2 * locking_lug_size);

            // Main hole (top to bottom)
            translate([0, 0, -edge_pad])
                cylinder(r = inner_radius, h = hose_connector_height + 2 * locking_lug_size + 2 * edge_pad);

            // Male adapter receiving space (room for its wall)
            translate([0, 0, -edge_pad])
                cylinder(r = hose_diameter / 2 + edge_pad, h = 2 * locking_lug_size + slot_cover + edge_pad);

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
        outside_ring();

        if (tube_extension) {
            // Add slanted slim/wide tube connect
            translate([0, 0, slim_height + 2 * locking_lug_size])
                tube_transition(inner_radius, outer_radius + tolerance_gap, transition_height, wall_thickness);

            // Add wider tube
            translate([0, 0, slim_height + 2 * locking_lug_size + transition_height])
                difference() {
                    cylinder(r = outer_radius + wall_thickness + tolerance_gap, h = extension_height);
                    translate([0, 0, -locking_lug_size])
                        cylinder(r = outer_radius + tolerance_gap, h = extension_height + 2 * locking_lug_size);
                }
        }

        // Convex Quarter-Circle Lead-in Rim (Points Upward & Outward)
        translate([0, 0, hose_connector_height + 2 * locking_lug_size])
            top_lead_in_rim();
    }

    // ====================================================================
    // For the adapter geometry, this connects the ring with the wider tube
    module tube_transition(r1, r2, height, thickness) {
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
    module top_lead_in_rim() {
        rotate_extrude() {
            translate([top_ring_radius, 0, 0]) {
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
    module outside_ring() {
        top_chamfer_size = ring_outer_radius - ring_inner_radius + ring_wall_thickness;

        // The ring body
        difference() {
            // The ring body, inner cylinders get subtracted later to make it hollow
            cylinder(r = ring_outer_radius + ring_wall_thickness, h = ring_height);

            // Bottom ring chamfer (print bed)
            rotate_extrude()
                polygon([
                    [ring_outer_radius + ring_wall_thickness - ring_chamfer, 0],
                    [ring_outer_radius + ring_wall_thickness + edge_pad, 0],
                    [ring_outer_radius + ring_wall_thickness + edge_pad, ring_chamfer + edge_pad]
                ]);

            // Cut out the slots
            bayonet_slots();

            translate([0, 0, -edge_pad])
                cylinder(r = outer_radius + 1.75 * tolerance_gap, h = ring_height + edge_pad);
        }

        // Top ring chamfer
        rotate_extrude()
            polygon([
                [inner_radius + tolerance_gap, ring_height - edge_pad],
                [ring_inner_radius + top_chamfer_size, ring_height - edge_pad],
                [inner_radius + tolerance_gap, ring_height + .5 * top_chamfer_size]
            ]);

        // Open / close indicators
        for (slot_center = [45 : 90 : 315]) {
            // Open (hollowed out circle)
            rotate([0, 0, slot_center - .75 * indicator_lug_angle]) {
                translate([ring_outer_radius + .75 * ring_wall_thickness, 0, 1.5 * locking_lug_size])
                    difference() {
                        scale([.5, 2, 2])
                            sphere(r = ring_wall_thickness, $fn = $fn);
                        rotate([0, 90, 0])
                            cylinder(r = 1.25 * ring_wall_thickness, h = 2 * ring_wall_thickness, $fn = $fn);
                    }
            }

            // Left / right arrows
            rotate([0, 0, slot_center + 0 * indicator_lug_angle]) {
                translate([ring_outer_radius + .75 * ring_wall_thickness, 0, 1.5 * locking_lug_size])
                    scale([.75, 6, 2])
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
            rotate([0, 0, slot_center + .75 * indicator_lug_angle]) {
                translate([ring_outer_radius + .75 * ring_wall_thickness, 0, 1.5 * locking_lug_size])
                    scale([.5, 2, 2])
                        sphere(r = ring_wall_thickness, $fn = $fn);
            }
        }
    }

    // ====================================================================
    // Positive model of the L-shaped slots; gets carved out in the
    // outside_ring() module
    module bayonet_slots() {
        lug_angle = (locking_lug_length + tolerance_gap + 2 * edge_pad) / lug_center_radius * 180 / PI;
        lug_angle_padded = (locking_lug_length + tolerance_gap + 3 * edge_pad) / lug_center_radius * 180 / PI;

        // Create 4 slots
        for (slot_center = [45 : 90 : 315]) {
            rotate([0, 0, slot_center - lug_angle / 2]) {
                // Lug entry port, open to the bottom
                rotate_extrude(angle = lug_angle_padded, convexity = 2)
                    polygon([
                        [ring_inner_radius - edge_pad, -edge_pad],
                        [slot_outer_radius + edge_pad, -edge_pad],
                        [slot_outer_radius + edge_pad, slot_depth - locking_lug_size + edge_pad],
                        [ring_inner_radius - edge_pad, slot_depth - locking_lug_size + edge_pad]
                    ]);

                // Tighter lug space, just the triangles
                rotate_extrude(angle = 2 * lug_angle_padded, convexity = 2)
                    polygon([
                        [ring_inner_radius - edge_pad, slot_cover - edge_pad],
                        [slot_outer_radius + edge_pad, locking_lug_size + slot_cover + edge_pad],
                        [ring_inner_radius - edge_pad, locking_lug_size + slot_cover + edge_pad]
                    ]);
                rotate_extrude(angle = 2 * lug_angle_padded, convexity = 2)
                    polygon([
                        [ring_inner_radius - edge_pad, locking_lug_size + slot_cover - edge_pad],
                        [slot_outer_radius + edge_pad, locking_lug_size + slot_cover - edge_pad],
                        [ring_inner_radius - edge_pad, slot_depth + edge_pad]
                    ]);
            }

            // Locking lug space (lowers bottom of the space to catch the lug)
            rotate([0, 0, slot_center + lug_angle]) {
                // Lowered bottom triangle
                rotate_extrude(angle = lug_angle_padded, convexity = 2)
                    polygon([
                        [ring_inner_radius - edge_pad, slot_cover - edge_pad - wall_thickness / 2],
                        [slot_outer_radius + edge_pad, locking_lug_size + slot_cover + edge_pad - wall_thickness / 2],
                        [ring_inner_radius - edge_pad, locking_lug_size + slot_cover + edge_pad - wall_thickness / 2]
                    ]);
                // Rect space to meet the lowered bottom triangle
                rotate_extrude(angle = lug_angle_padded, convexity = 2)
                    polygon([
                        [ring_inner_radius - edge_pad, slot_cover - edge_pad + locking_lug_size - wall_thickness / 2],
                        [slot_outer_radius + edge_pad, slot_cover - edge_pad + locking_lug_size - wall_thickness / 2],
                        [slot_outer_radius + edge_pad, slot_cover + edge_pad + locking_lug_size + wall_thickness / 2],
                        [ring_inner_radius - edge_pad, slot_cover + edge_pad + locking_lug_size + wall_thickness / 2],
                    ]);
                // Upper triangle
                rotate_extrude(angle = lug_angle_padded, convexity = 2)
                    polygon([
                        [ring_inner_radius - edge_pad, locking_lug_size + slot_cover - edge_pad],
                        [slot_outer_radius + edge_pad, locking_lug_size + slot_cover - edge_pad],
                        [ring_inner_radius - edge_pad, slot_depth + edge_pad]
                    ]);
            }
        }
    }
