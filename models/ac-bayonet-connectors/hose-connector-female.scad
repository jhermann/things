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

    // ====================================================================
    // Main Assembly
    // ====================================================================
    union() {
        // Main Hose Connector Cylinder
        slim_height = tube_extension ? (5 * wall_thickness) : hose_connector_height;
        difference() {
            cylinder(r = outer_radius, h = slim_height + 2 * locking_lug_size);
            translate([0, 0, -edge_pad])
                cylinder(r = inner_radius, h = hose_connector_height + 2 * locking_lug_size + 2 * edge_pad);
            translate([0, 0, -edge_pad])
                cylinder(r = outer_radius, h = 2 * locking_lug_size + slot_cover + edge_pad);
            rotate_extrude()
                polygon([
                    [inner_radius - edge_pad, 2 * locking_lug_size + slot_cover + wall_thickness],
                    [inner_radius - edge_pad, 2 * locking_lug_size + slot_cover],
                    [outer_radius + edge_pad, 2 * locking_lug_size + slot_cover]
                ]);
        }

        // Continuous base ring around the outside of the tube, with locking slots
        outside_ring();

        if (tube_extension) {
            transition_height = 2 * locking_lug_size;
            extension_height = hose_connector_height - transition_height - slim_height;
            translate([0, 0, slim_height + 2 * locking_lug_size])
                tube_transition(inner_radius, outer_radius + tolerance_gap, transition_height, wall_thickness);
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

    module tube_transition(r1, r2, height, thickness) {
        // Rotate_extrude spins a 2D profile 360 degrees around the Z-axis
        rotate_extrude() {
            polygon(points=[
                [r1, 0],
                [r2, height],
                [r2 + thickness, height],
                [r1 + thickness, 0]
            ]);
        }
    }

    // Convex Lead-In Rim
    // Profile: A solid 90° quarter-circle arc centered at (inner_radius, 0),
    // sweeping UPWARD and OUTWARD towards outer_radius.
    module top_lead_in_rim() {
        top_ring_radius = tube_extension ? (outer_radius + tolerance_gap) : inner_radius;
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

    module outside_ring() {
        // Set ring_wall_thickness to 0 to expose bayonet slots
        ring_wall_thickness = 1 * wall_thickness;
        ring_height = 2 * locking_lug_size + 4 * wall_thickness;
        ring_outer_radius = hose_diameter / 2 + locking_lug_size;
        ring_chamfer = wall_thickness / 4;

        difference() {
            cylinder(r = ring_outer_radius + ring_wall_thickness, h = ring_height);

            // Top ring chamfer
            rotate_extrude()
                polygon([
                    [ring_outer_radius + ring_wall_thickness - ring_chamfer, ring_height],
                    [ring_outer_radius + ring_wall_thickness + edge_pad, ring_height],
                    [ring_outer_radius + ring_wall_thickness + edge_pad, ring_height - ring_chamfer - edge_pad]
                ]);

            // Bottom ring chamfer
            rotate_extrude()
                polygon([
                    [ring_outer_radius + ring_wall_thickness - ring_chamfer, 0],
                    [ring_outer_radius + ring_wall_thickness + edge_pad, 0],
                    [ring_outer_radius + ring_wall_thickness + edge_pad, ring_chamfer + edge_pad]
                ]);

            bayonet_slots();

            translate([0, 0, -edge_pad])
                cylinder(r = outer_radius + 1.5 * tolerance_gap, h = ring_height + 2 * edge_pad);
        }

        // Tube / ring chamfer
        rotate_extrude()
            polygon([
                [outer_radius, ring_height],
                [outer_radius + ring_chamfer, ring_height],
                [outer_radius, ring_height + ring_chamfer]
            ]);
    }

    module bayonet_slots() {
        // L-shaped slots
        ring_inner_radius = outer_radius + 1.5 * tolerance_gap;
        slot_outer_radius = ring_inner_radius + locking_lug_size;
        lug_center_radius = (ring_inner_radius + slot_outer_radius) / 2;
        lug_angle = (locking_lug_length + tolerance_gap + 2 * edge_pad) / lug_center_radius * 180 / PI;
        slot_depth = 2 * locking_lug_size + slot_cover;

        for (slot_center = [45 : 90 : 315]) {
            rotate([0, 0, slot_center - lug_angle / 2]) {
                // Lug entry
                rotate_extrude(angle = lug_angle, convexity = 2)
                    polygon([
                        [ring_inner_radius - edge_pad, -edge_pad],
                        [slot_outer_radius + edge_pad, -edge_pad],
                        [slot_outer_radius + edge_pad, slot_depth - locking_lug_size + edge_pad],
                        [ring_inner_radius - edge_pad, slot_depth - locking_lug_size + edge_pad]
                    ]);

                // Tighter lug space
                rotate_extrude(angle = 2 * lug_angle, convexity = 2)
                    polygon([
                        [ring_inner_radius - edge_pad, slot_cover - edge_pad],
                        [slot_outer_radius + edge_pad, locking_lug_size + slot_cover + edge_pad],
                        [ring_inner_radius - edge_pad, locking_lug_size + slot_cover + edge_pad]
                    ]);
                rotate_extrude(angle = 2 * lug_angle, convexity = 2)
                    polygon([
                        [ring_inner_radius - edge_pad, locking_lug_size + slot_cover - edge_pad],
                        [slot_outer_radius + edge_pad, locking_lug_size + slot_cover - edge_pad],
                        [ring_inner_radius - edge_pad, slot_depth + edge_pad]
                    ]);
            }

            rotate([0, 0, slot_center + lug_angle]) {
                // Locking lug space
                rotate_extrude(angle = lug_angle, convexity = 2)
                    polygon([
                        [ring_inner_radius - edge_pad, slot_cover - edge_pad - wall_thickness / 2],
                        [slot_outer_radius + edge_pad, locking_lug_size + slot_cover + edge_pad - wall_thickness / 2],
                        [ring_inner_radius - edge_pad, locking_lug_size + slot_cover + edge_pad - wall_thickness / 2]
                    ]);
                rotate_extrude(angle = lug_angle, convexity = 2)
                    polygon([
                        [ring_inner_radius - edge_pad, slot_cover - edge_pad + locking_lug_size - wall_thickness / 2],
                        [slot_outer_radius + edge_pad, slot_cover - edge_pad + locking_lug_size - wall_thickness / 2],
                        [slot_outer_radius + edge_pad, slot_cover + edge_pad + locking_lug_size + wall_thickness / 2],
                        [ring_inner_radius - edge_pad, slot_cover + edge_pad + locking_lug_size + wall_thickness / 2],
                    ]);
                rotate_extrude(angle = lug_angle, convexity = 2)
                    polygon([
                        [ring_inner_radius - edge_pad, locking_lug_size + slot_cover - edge_pad],
                        [slot_outer_radius + edge_pad, locking_lug_size + slot_cover - edge_pad],
                        [ring_inner_radius - edge_pad, slot_depth + edge_pad]
                    ]);
            }
        }
    }
