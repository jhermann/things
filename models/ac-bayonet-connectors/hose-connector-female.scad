    // ====================================================================
    // Parametric AC Hose Bayonet Connector (Female)
    // ====================================================================

    /* [Hose Connector] */
    hose_diameter           = 150;   // Nominal outer diameter of the hose (mm)
    hose_connector_height   = 55;    // Height of straight cylindrical section (mm)
    wall_thickness          = 2.5;   // Wall thickness for connector & top rim (mm)
    tolerance_gap           = 0.15;  // Subtracted from outer diameter for fit (mm)

    /* [Connector Ring] */
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

        // Continuous base ring around the outside of the tube
        outside_ring();
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

    module outside_ring() {
        ring_height = locking_lug_size + 4 * wall_thickness;
        ring_outer_radius = hose_diameter / 2 + locking_lug_size;
        ring_chamfer = wall_thickness / 4;

        difference() {
            cylinder(r = ring_outer_radius, h = ring_height);

            rotate_extrude()
                polygon([
                    [ring_outer_radius - ring_chamfer, ring_height],
                    [ring_outer_radius + edge_pad, ring_height],
                    [ring_outer_radius + edge_pad, ring_height - ring_chamfer - edge_pad]
                ]);

            rotate_extrude()
                polygon([
                    [ring_outer_radius - ring_chamfer, 0],
                    [ring_outer_radius + edge_pad, 0],
                    [ring_outer_radius + edge_pad, ring_chamfer + edge_pad]
                ]);

            translate([0, 0, -edge_pad])
                cylinder(r = outer_radius, h = ring_height + 2 * edge_pad);
        }
    }
