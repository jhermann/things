// ==========================================
// Parametric AC Exhaust Vent Cover
// ==========================================

// --- Parameters ---

// Vent cover
vent_diameter     = 144.65; // Nominal outer diameter of the vent
vent_tube_depth   = 35;     // Height of the straight cylindrical section
wall_thickness    = 1.5;    // Wall thickness for main cylinder
tolerance_gap     = 0.15;   // Clearance subtracted from outer radius

// Vent rim
rim_size           = 10;     // Extra margin width added around cylinder
rim_thickness      = 3;      // Height/thickness of the rim
rim_bottom_chamfer = 1;      // Chamfer distance at bottom outer edge

// Grill fins
grill_distance     = 12.5;   // Spacing of the grill fins
grill_angle        = 45;     // Angle of the grill fins (deg)
grill_height       = 15;     // Height of angled grill fins & stabilizer
grill_thickness    = 1;      // Wall thickness of the grill fins

// Spring tongues
tongue_size        = 10;     // Height and width of the springs
tongue_thickness   = 1.0;    // Reduced thickness for flexibility (thinner than wall)

// Quality
$fn = 120;

// --- Derived Calculations ---
eps = 0.05; // Small overlap value for CSG clean operations

outer_radius  = (vent_diameter / 2) - tolerance_gap;
inner_radius  = outer_radius - wall_thickness;
tongue_inner_r = outer_radius - tongue_thickness;

// Fin depth along the slanted direction to achieve exact `grill_height` vertically
fin_depth = grill_height / sin(grill_angle);

// --- Main Assembly ---
union() {
    difference() {
        // ----------------------------------------------------
        // 1. POSITIVE GEOMETRY: Solid Tube Body + Rim + Bumps
        // ----------------------------------------------------
        union() {
            // Main Solid Outer Cylinder
            cylinder(r = outer_radius, h = vent_tube_depth);
            
            // Outer Rim at bottom
            difference() {
                cylinder(r = outer_radius + rim_size, h = rim_thickness);
                
                // Bottom chamfer
                if (rim_bottom_chamfer > 0) {
                    translate([0, 0, -eps])
                        difference() {
                            cylinder(r = outer_radius + rim_size + eps, h = rim_bottom_chamfer + eps);
                            translate([0, 0, -eps])
                                cylinder(r1 = outer_radius + rim_size - rim_bottom_chamfer, 
                                         r2 = outer_radius + rim_size, 
                                         h = rim_bottom_chamfer + 2*eps);
                        }
                }
            }
            
            // Ellipsoid Friction Segments on Spring Tongues
            for (a = [0, 90, 180, 270]) {
                rotate([0, 0, a])
                    translate([0, outer_radius, vent_tube_depth - (tongue_size / 2)])
                        ellipsoid_segment();
            }
        }

        // ----------------------------------------------------
        // 2. NEGATIVE GEOMETRY (Subtractions)
        // ----------------------------------------------------

        // A. Main Inner Cavity: Hollows out tube EXCEPT for the spring tongue zones
        difference() {
            translate([0, 0, -eps])
                cylinder(r = inner_radius, h = vent_tube_depth + 2*eps);
            
            // Protect the 4 tongue height zones from being hollowed out prematurely
            for (a = [0, 90, 180, 270]) {
                rotate([0, 0, a])
                    translate([-tongue_size/2, 0, vent_tube_depth - tongue_size])
                        cube([tongue_size, outer_radius + eps, tongue_size + eps]);
            }
        }

        // B. Tongue Thinning Cut & Vertical Slits
        for (a = [0, 90, 180, 270]) {
            rotate([0, 0, a]) {
                
                // --- THINNING CUT ---
                // Cuts away inner wall behind the tongue down to tongue_inner_r (1.0mm thickness).
                // Extends past the inner edge into the hollow tube to ensure zero wall remnants.
                translate([-tongue_size/2, 0, vent_tube_depth - tongue_size - eps])
                    cube([tongue_size, tongue_inner_r, tongue_size + 2*eps]);

                // --- TWO VERTICAL SLITS ---
                // Cuts slits of width `wall_thickness` along the sides of the tongue
                for (x_offset = [-tongue_size/2 - wall_thickness, tongue_size/2]) {
                    translate([x_offset, inner_radius - 1, vent_tube_depth - tongue_size - eps])
                        cube([wall_thickness, wall_thickness + (outer_radius - inner_radius) + 2*tolerance_gap + 2, tongue_size + 2*eps]);
                }
            }
        }
    }

    // ----------------------------------------------------
    // 3. INTEGRATED GRILL & CENTRAL STABILIZER
    // ----------------------------------------------------
    intersection() {
        cylinder(r = outer_radius, h = grill_height);
        
        union() {
            // Angled Grill Fins
            for (x = [-outer_radius : grill_distance : outer_radius]) {
                translate([x, 0, 0])
                    rotate([0, -grill_angle, 0])
                        translate([-grill_thickness/2, -outer_radius, 0])
                            cube([grill_thickness, outer_radius * 2, fin_depth]);
            }
            
            // Vertical Central Stabilizer
            translate([-outer_radius, -grill_thickness/2, 0])
                cube([outer_radius * 2, grill_thickness, grill_height]);
        }
    }
}

// --- Helper Module: Ellipsoid Segment ---
module ellipsoid_segment() {
    ellip_d = tongue_size - wall_thickness;
    ellip_r = ellip_d / 2;
    overlap = wall_thickness / 2;
    protrusion = 2 * tolerance_gap;

    intersection() {
        // Limit bounding box to ensure clipping at slits
        translate([-tongue_size/2, -outer_radius - 10, -ellip_r])
            cube([tongue_size, outer_radius + 20, ellip_d]);

        // Scaled Ellipsoid
        translate([0, 0, 0])
            scale([ellip_r, protrusion + overlap, ellip_r])
                sphere(r = 1);
    }
}