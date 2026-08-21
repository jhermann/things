// ====================================================================
// Parametric AC Hose Adapter with Insect Grill
// ====================================================================

/* [Hose Connector] */
hose_diameter           = 150;   // Nominal outer diameter of the hose (mm)
hose_connector_height   = 55;    // Height of straight cylindrical section (mm)
wall_thickness          = 2.5;   // Wall thickness for connector & top rim (mm)
tolerance_gap           = 0.15;  // Subtracted from outer diameter for fit (mm)

/* [Base Plate] */
base_plate_rim          = 15;    // Extra width around cylinder for base plate (mm)
base_plate_thickness    = 4;     // Height/thickness of base plate (mm)
base_corner_radius      = 10;    // Corner fillet radius for square plate (mm)
base_bottom_chamfer     = 1.5;   // Chamfer size on bottom outer edge (mm)
foam_tape_groove_width  = 10;    // Width of foam tape groove (mm)
foam_tape_thickness     = 1;     // Foam tape thickness (90% depth cutout) (mm)

/* [Mounting Holes] */
add_holes               = true;  // Add four M4 screw holes
m4_hole_diameter        = 4.25;   // M4 clearance hole diameter (mm)

/* [Insect Screen] */
grid_hole_size          = 2.1;   // Flat-to-flat inner diameter of hex cell (mm)
grid_wall_thickness     = 0.6;   // Shared wall thickness of hex grid (mm)
grid_height             = 1.2;   // Height of hex grid (mm)

/* [Quality] */
$fn = 120;                       // Circle resolution parameter

// ====================================================================
// Derived Dimensions
// ====================================================================
outer_radius = (hose_diameter / 2) - tolerance_gap;
inner_radius = outer_radius - wall_thickness;
base_size    = (outer_radius + base_plate_rim) * 2;
groove_depth = foam_tape_thickness * 0.9;
edge_pad     = 0.2; // Padding to guarantee clean CSG subtractions

// ====================================================================
// Main Assembly
// ====================================================================
union() {
    // 1. Base Plate with Foam Tape Grooves strictly cut out from top
    difference() {
        // Main Chamfered & Rounded Base Plate Block
        base_plate_shape(base_size, base_plate_thickness, base_corner_radius, base_bottom_chamfer);
        
        // Inner Hole through base plate
        translate([0, 0, -edge_pad])
            cylinder(r = inner_radius, h = base_plate_thickness + 2 * edge_pad);
            
        // Foam Tape Recessed Grooves cut directly out of the top surface
        foam_tape_grooves();

        // Optional M4 screw holes near each corner
        if (add_holes)
            mounting_screw_holes();
    }

    // 2. Main Hose Connector Cylinder
    difference() {
        cylinder(r = outer_radius, h = hose_connector_height);
        translate([0, 0, -edge_pad])
            cylinder(r = inner_radius, h = hose_connector_height + 2 * edge_pad);
    }

    // 3. Convex Quarter-Circle Lead-in Rim (Points Upward & Outward)
    translate([0, 0, hose_connector_height])
        top_lead_in_rim();

    // 4. Hex Insect Screen inside the inner hole
    intersection() {
        cylinder(r = inner_radius, h = grid_height);
        
        honeycomb_grid(
            size = base_size,
            height = grid_height,
            cell_flat_to_flat = grid_hole_size,
            wall_thick = grid_wall_thickness
        );
    }
}

// ====================================================================
// Sub-Modules
// ====================================================================

// Base plate with rounded corners and bottom edge chamfer
module base_plate_shape(s, h, r, c) {
    half_s = s / 2;
    hull() {
        for (x = [-half_s + r, half_s - r]) {
            for (y = [-half_s + r, half_s - r]) {
                translate([x, y, 0])
                    corner_chamfered_cylinder(h = h, r = r, c = c);
            }
        }
    }
}

// Individual corner post with 45-degree chamfer at the bottom
module corner_chamfered_cylinder(h, r, c) {
    union() {
        cylinder(r1 = r - c, r2 = r, h = c);
        translate([0, 0, c])
            cylinder(r = r, h = h - c);
    }
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

// Perimeter grooves cut directly out of the base plate top surface
module foam_tape_grooves() {
    half_s = base_size / 2;
    
    // Groove length formula extended by chamfer size on both ends (+ 2 * chamfer)
    groove_len = base_size - (2 * base_corner_radius);
    
    // Positioned inwards relative to outer edge, accounting for chamfer
    groove_y_center = half_s - base_bottom_chamfer - (foam_tape_groove_width / 2);
    
    // Cutting depth starts at top face (z = base_plate_thickness) and goes down by groove_depth
    z_start = base_plate_thickness - groove_depth;
    
    for (i = [0 : 3]) {
        rotate([0, 0, i * 90]) {
            translate([-groove_len / 2, groove_y_center - (foam_tape_groove_width / 2), z_start]) {
                cube([groove_len, foam_tape_groove_width, groove_depth + edge_pad]);
            }
        }
    }
}

// Four M4 clearance holes positioned inward from the base plate rim
module mounting_screw_holes() {
    half_s = base_size / 2;
    hole_offset = half_s - foam_tape_groove_width - (4 * base_bottom_chamfer);

    for (x = [-hole_offset, hole_offset]) {
        for (y = [-hole_offset, hole_offset]) {
            translate([x, y, -edge_pad])
                cylinder(
                    d = m4_hole_diameter,
                    h = base_plate_thickness + (2 * edge_pad)
                );
        }
    }
}

// Honeycomb Screen Module
module honeycomb_grid(size, height, cell_flat_to_flat, wall_thick) {
    r_inner = cell_flat_to_flat / 2;
    r_outer = r_inner / cos(30);
    
    x_spacing = (r_inner * 2) + wall_thick;
    y_spacing = x_spacing * sin(60);
    
    cols = ceil(size / x_spacing) + 2;
    rows = ceil(size / y_spacing) + 2;
    
    difference() {
        translate([-size/2, -size/2, 0])
            cube([size, size, height]);
        
        translate([- (cols * x_spacing) / 2, - (rows * y_spacing) / 2, 0]) {
            for (col = [0 : cols]) {
                for (row = [0 : rows]) {
                    x_off = (row % 2 == 0) ? 0 : x_spacing / 2;
                    x_pos = (col * x_spacing) + x_off;
                    y_pos = row * y_spacing;
                    
                    translate([x_pos, y_pos, -edge_pad])
                        rotate([0, 0, 30])
                        cylinder(r = r_outer, h = height + (edge_pad * 2), $fn = 6);
                }
            }
        }
    }
}