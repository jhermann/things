/* [Box Dimensions] */
// Total outer depth of the box (mm, X axis)
depth = 200; // [10:5:500]

// Total outer width of the box (mm, Y axis)
width = 40; // [10:5:200]

// Total outer height of the box (mm, Z axis)
height = 230; // [10:5:500]

// Thickness of all walls (mm)
wall_thickness = 2; // [0.8:0.2:10]


/* [Corner Arc] */
// Radius of the corner arc and size of the corner square (mm)
arc_radius = 32; // [1:1:200]

// Percentage of arc radius to remove outer spike (%)
clip_percent = 15; // [0:1:100]

// Actual clipping distance
clip_amount = arc_radius * clip_percent / 100;


/* [Outer Rim] */
// Thickness of the rim (mm)
rim_thickness = 1.5; // [0.25:0.25:200]

// Width of the rim lip extending along the outer walls (mm)
rim_size = 10; // [1:0.5:100]

// Angle for support chamfers (45° or less is OK for modern printers)
support_angle = 45; // [10:5:60]


/* [Print Quality] */
// Smoothness of curved surfaces
$fn = 64; // [16, 32, 64, 128]


// ============================================================
// MAIN ASSEMBLY
// ============================================================

open_box_with_arc_corners();


module open_box_with_arc_corners() {

    union() {

        // 1. Bottom Wall
        cube([
            depth,
            width,
            wall_thickness
        ]);


        // 2. Top Wall
        translate([
            0,
            0,
            height - wall_thickness
        ])
            cube([
                depth,
                width,
                wall_thickness
            ]);


        // 3. Back Wall
        translate([
            0,
            width - wall_thickness,
            0
        ])
            cube([
                depth,
                wall_thickness,
                height
            ]);


        // 4. Right Wall
        translate([
            depth - wall_thickness,
            0,
            0
        ])
            cube([
                wall_thickness,
                width,
                height
            ]);


        // 5. Bottom Corner Arc Piece
        corner_arc_extension(
            arc_radius,
            wall_thickness
        );


        // 6. Top Corner Arc Piece
        translate([
            0,
            0,
            height - wall_thickness
        ])
            corner_arc_extension(
                arc_radius,
                wall_thickness
            );


        // 7. Outer Rim Assembly
        outer_rim();
    }
}


// ============================================================
// CORNER ARC GENERATOR
// ============================================================
//
// The original arc occupies:
//
//     X = 0 ... r
//     Y = -r ... 0
//
// The main box is on the +Y side.
//
// Therefore the side AWAY from the main box is:
//
//     Y = -r
//
// We clip that side with a BOX.
//
// Example:
//
//     r = 15
//     clip_percent = 10
//     clip_amount = 1.5
//
// Original Y range:
//
//     -15 ... 0
//
// New Y range:
//
//     -13.5 ... 0
//
// The X dimension is NOT shortened.
//
// ============================================================

module corner_arc_extension(r, t) {

    intersection() {

        // ====================================================
        // CLIPPING BOX
        // ====================================================
        //
        // Keep everything from:
        //
        //     Y = -r + clip_amount
        //
        // through:
        //
        //     Y = +infinity
        //
        // This removes the outer 10% of the extension on the
        // side away from the main box.
        //
        // X is deliberately oversized so it is NOT clipped.
        // Z is deliberately oversized so it is NOT clipped.
        // ====================================================

        translate([
            -1,
            -r + clip_amount,
            -1
        ])
            cube([
                r + 2,
                r + 2,
                t + 2
            ]);


        // ====================================================
        // ORIGINAL CORNER ARC
        // ====================================================

        linear_extrude(height = t) {

            rotate([0, 0, 90]) {

                difference() {

                    translate([
                        -r,
                        -r
                    ])
                        square([
                            r,
                            r
                        ],
                        center = false
                    );


                    translate([
                        -r,
                        -r
                    ])
                        circle(
                            r = r
                        );
                }
            }
        }
    }
}


// ============================================================
// COMPOUND MITER CORNER GENERATOR (TOP-REAR)
// ============================================================

module mitered_corner_wedge_hull_top(
    size_x,
    rim_thick,
    supp_base,
    size_z
) {

    hull() {

        // Horizontal profile at Z = height

        translate([
            0,
            0,
            0
        ])
            rotate([0, 90, 0])
                linear_extrude(height = 0.01)
                    polygon(points = [
                        [0, 0],
                        [0, rim_thick],
                        [-size_z, rim_thick],
                        [0, rim_thick + supp_base]
                    ]);


        // Vertical profile at X = depth

        translate([
            0,
            0,
            0
        ])
            linear_extrude(height = 0.01)
                polygon(points = [
                    [0, 0],
                    [0, rim_thick],
                    [size_x, rim_thick],
                    [0, rim_thick + supp_base]
                ]);
    }
}


// ============================================================
// COMPOUND MITER CORNER GENERATOR (BOTTOM-REAR)
// ============================================================

module mitered_corner_wedge_hull_bottom(
    size_x,
    rim_thick,
    supp_base,
    size_z
) {

    hull() {

        // Horizontal profile at Z = 0

        translate([
            0,
            0,
            0
        ])
            rotate([0, 90, 0])
                linear_extrude(height = 0.01)
                    polygon(points = [
                        [0, rim_thick],
                        [size_z, rim_thick],
                        [0, rim_thick + supp_base]
                    ]);


        // Vertical profile at X = depth

        translate([
            0,
            0,
            0
        ])
            linear_extrude(height = 0.01)
                polygon(points = [
                    [0, 0],
                    [0, rim_thick],
                    [size_x, rim_thick],
                    [0, rim_thick + supp_base]
                ]);
    }
}


// ============================================================
// OUTER RIM GENERATOR
// ============================================================

module outer_rim() {

    // Length of the support leg along the outer wall
    support_base = rim_size / tan(support_angle);


    union() {

        // ====================================================
        // 1. BOTTOM EDGE RIM & SUPPORT
        // ====================================================

        translate([
            arc_radius,
            0,
            -rim_size
        ])
            cube([
                depth - arc_radius,
                rim_thickness,
                rim_size
            ]);


        // Bottom wedge

        translate([
            arc_radius,
            0,
            0
        ])
            rotate([0, 90, 0])
                linear_extrude(
                    height = depth - arc_radius
                )
                    polygon(points = [
                        [0, rim_thickness],
                        [rim_size, rim_thickness],
                        [0, rim_thickness + support_base]
                    ]);


        // ====================================================
        // 2. TOP EDGE RIM & SUPPORT
        // ====================================================

        translate([
            arc_radius,
            0,
            height
        ])
            cube([
                depth - arc_radius,
                rim_thickness,
                rim_size
            ]);


        // Top wedge

        translate([
            arc_radius,
            0,
            0
        ])
            rotate([0, 90, 0])
                linear_extrude(
                    height = depth - arc_radius
                )
                    polygon(points = [
                        [-height, rim_thickness],
                        [-(height + rim_size), rim_thickness],
                        [-height, rim_thickness + support_base]
                    ]);


        // ====================================================
        // 3. BACK EDGE RIM & VERTICAL SUPPORT
        // ====================================================

        translate([
            depth,
            0,
            0
        ])
            cube([
                rim_size,
                rim_thickness,
                height
            ]);


        // Back vertical wedge

        linear_extrude(
            height = height
        )
            polygon(points = [
                [depth, rim_thickness],
                [depth + rim_size, rim_thickness],
                [depth, rim_thickness + support_base]
            ]);


        // ====================================================
        // 4. CORNER CAPS WITH MITERED TRANSITIONS
        // ====================================================

        // Top-Rear Corner Transition

        translate([
            depth,
            0,
            height
        ])
            mitered_corner_wedge_hull_top(
                rim_size,
                rim_thickness,
                support_base,
                rim_size
            );


        // Bottom-Rear Corner Transition

        translate([
            depth,
            0,
            0
        ])
            mitered_corner_wedge_hull_bottom(
                rim_size,
                rim_thickness,
                support_base,
                rim_size
            );


        // ====================================================
        // 5. FLAT TRIANGULAR RIM CORNER FILLERS
        // ====================================================

        // Top-Rear Rim Filler Triangle

        translate([
            depth,
            rim_thickness,
            height
        ])
            rotate([90, 0, 0])
                linear_extrude(
                    height = rim_thickness
                )
                    polygon(points = [
                        [0, 0],
                        [rim_size, 0],
                        [0, rim_size]
                    ]);


        // Bottom-Rear Rim Filler Triangle

        translate([
            depth,
            rim_thickness,
            0
        ])
            rotate([90, 0, 0])
                linear_extrude(
                    height = rim_thickness
                )
                    polygon(points = [
                        [0, 0],
                        [0, -rim_size],
                        [rim_size, 0]
                    ]);
    }
}
