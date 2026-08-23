    // ====================================================================
    // Parametric AC Hose Bayonet Connector (Male)
    // ====================================================================

    /* [Hose Connector] */
    hose_diameter           = 150;   // Nominal outer diameter of the hose (mm)
    hose_connector_height   = 55;    // Height of straight cylindrical section (mm)
    wall_thickness          = 2.5;   // Wall thickness for connector & top rim (mm)
    tolerance_gap           = 0.15;  // Subtracted from outer diameter for fit (mm)

    /* [Locking Lugs] */
    locking_lug_length      = 15;    // Circumferential arc length of each lug (mm)
    locking_lug_size        = 5;     // Square radial and vertical cross-section (mm)

    /* [Quality] */
    $fn = 120;                       // Circle resolution parameter

    // ====================================================================
    // Derived Dimensions
    // ====================================================================
    outer_radius = (hose_diameter / 2) - tolerance_gap;
    inner_radius = outer_radius - wall_thickness;
    edge_pad     = 0.2; // Padding to guarantee clean CSG subtractions

    // ====================================================================
    // Main Assembly
    // ====================================================================
    union() {
        // Main Hose Connector Cylinder
        difference() {
            cylinder(r = outer_radius, h = hose_connector_height);
            translate([0, 0, -edge_pad])
                cylinder(r = inner_radius, h = hose_connector_height + 2 * edge_pad);
        }

        // Convex Quarter-Circle Lead-in Rim (Points Upward & Outward)
        translate([0, 0, hose_connector_height])
            top_lead_in_rim();

        // Square-section ring cut into four arced locking lugs, resting on the print plate
        locking_lugs();
    }

    // Convex Lead-In Rim
    // Profile: A solid 90° quarter-circle arc centered at (inner_radius, 0),
    // sweeping UPWARD and OUTWARD towards outer_radius.
    module top_lead_in_rim() {
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
    module locking_lugs() {
        ring_inner_radius = outer_radius;
        ring_outer_radius = ring_inner_radius + locking_lug_size;
        ring_height = locking_lug_size * 2;
        lug_center_radius = (ring_inner_radius + ring_outer_radius) / 2;
        lug_angle = locking_lug_length / lug_center_radius * 180 / PI;
        gap_angle = 90 - lug_angle;
        hole_count = floor(locking_lug_length / (3 * wall_thickness));
        hole_spacing = 3 * wall_thickness;
        hole_margin = (locking_lug_length - (hole_count * wall_thickness + (hole_count - 1) * 2 * wall_thickness)) / 2;

        difference() {
            rotate_extrude(convexity = 2)
                polygon([
                    [ring_inner_radius, 0],
                    [ring_outer_radius, 0],
                    [ring_outer_radius, ring_height],
                    [ring_inner_radius, ring_height]
                ]);

            rotate_extrude(convexity = 2)
                polygon([
                    [ring_inner_radius, ring_height],
                    [ring_outer_radius + edge_pad, locking_lug_size],
                    [ring_outer_radius + edge_pad, ring_height]
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

