// ============================================================
// FLUSH THREADED CONTAINER + LID
// ============================================================
//
// - Lid outside diameter = container outside diameter
// - Threaded neck is recessed below the body OD
// - Thread has a thick trapezoidal Z profile
// - Thread is deliberately overlapped into the neck
//   so it cannot "hover"
// - Matching internal thread in the lid
//
// ============================================================

$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.1;


// ============================================================
// PARAMETERS
// ============================================================

outer_radius = 20;
wall = 2;

body_height = 30;
lid_height = 12;

// ------------------------------------------------------------
// THREAD
// ------------------------------------------------------------

pitch = 3;

// Radial height of thread
thread_height = 2;

// Axial thickness of the thread ridge.
// Larger = thicker / more pronounced in Z.
thread_z = 1.8;

// Number of turns
thread_turns = 2.5;

// Thread clearance
clearance = 0.30;

// Amount the thread base penetrates the neck.
// This prevents a floating/hovering thread.
thread_overlap = 0.30;

// ------------------------------------------------------------
// CHAMFERS
// ------------------------------------------------------------

// Leg length of the 45 degree chamfer applied to sharp outer edges.
chamfer = 1;

// ------------------------------------------------------------
// CSG SAFETY PADDING
// ------------------------------------------------------------

edge_pad     = 0.25; // Padding to guarantee clean CSG subtractions

// ------------------------------------------------------------
// LID GRIP RIBBING
// ------------------------------------------------------------

// Vertical ribs around the lid exterior for grip.
rib_count = 72;
rib_width = 1;
rib_height = 0.6;
rib_corner_radius = 0.2;


// ============================================================
// DERIVED THREAD GEOMETRY
// ============================================================

// Lid must remain flush with the 20 mm container body.
//
// The lid has a 2 mm wall, so its usable inside radius is:
//
//     20 - 2 = 18 mm
//
// Allowing clearance:
//
//     male thread maximum radius < 18 mm
//
// Therefore the threaded neck is recessed considerably.
//
// ------------------------------------------------------------

lid_inner_radius = outer_radius - wall;

male_thread_outer_radius =
    lid_inner_radius - clearance;

neck_radius =
    male_thread_outer_radius - thread_height;


// Thread length
thread_length = pitch * thread_turns;


// Start thread near top of container
thread_start =
    body_height - thread_length;


// ============================================================
// TRAPEZOIDAL HELICAL THREAD
// ============================================================
//
// The thread has:
//
//       ______
//      /      \
// _____/        \_____
//
// instead of a razor-thin triangular ridge.
//
// `radius` is the neck surface.
// `thread_height` is radial thread depth (horizontal reach).
// `thread_z` is axial thickness (vertical reach).
//
// Built as a union of hull()s between successive thin radial
// slices swept around the axis. Unlike a plain
// linear_extrude(twist=...) of a profile offset in the
// tangential direction, this keeps `thread_height` and
// `thread_z` as direct, independent measurements in the
// radial and Z directions - not scaled down by
// pitch / (2*pi*radius).
//

function thread_profile(thread_height, thread_z) = [
    [0,                     -thread_z / 2],
    [thread_height * 0.35,  -thread_z / 2],
    [thread_height,         -thread_z * 0.25],
    [thread_height,          thread_z * 0.25],
    [thread_height * 0.35,   thread_z / 2],
    [0,                      thread_z / 2]
];

// Places the profile (radial, axial) as a thin slab in the
// XZ half-plane at the given angle/height around the Z axis.
module thread_slice(theta, z_center, radius, thread_height, thread_z) {
    translate([0, 0, z_center])
        rotate([0, 0, theta])
            translate([radius, 0, 0])
                rotate([90, 0, 0])
                    linear_extrude(height = 0.001)
                        polygon(thread_profile(thread_height, thread_z));
}

module helical_thread(
    radius,
    height,
    pitch,
    thread_height,
    thread_z
) {

    turns = height / pitch;

    steps_per_turn = 32;
    steps = max(16, round(turns * steps_per_turn));

    for (i = [0 : steps - 1]) {
        theta0 = i * 360 * turns / steps;
        theta1 = (i + 1) * 360 * turns / steps;
        z0 = i * height / steps;
        z1 = (i + 1) * height / steps;

        hull() {
            thread_slice(theta0, z0, radius, thread_height, thread_z);
            thread_slice(theta1, z1, radius, thread_height, thread_z);
        }
    }
}

module external_thread(
    radius,
    height,
    pitch,
    thread_height,
    thread_z
) {
    helical_thread(radius, height, pitch, thread_height, thread_z);
}


// ============================================================
// INTERNAL THREAD CUTTER
// ============================================================
//
// Same profile as external thread, but enlarged by clearance.
//
// This is subtracted from the lid.
//

module internal_thread(
    radius,
    height,
    pitch,
    thread_height,
    thread_z
) {
    helical_thread(radius, height, pitch, thread_height, thread_z);
}


// ============================================================
// LID GRIP RIBBING
// ============================================================
//
// Evenly spaced vertical ribs around the lid's outer wall,
// matching the knurled-grip look of the reference design.
//

// Ribs stop short of the top/bottom chamfers so they don't
// poke through the sloped edges, and stop a further rib
// thickness short of that so their flat ends stay tucked
// inside the rounded rings instead of poking past them.
module lid_rib(radius, height) {
    translate([radius, 0, chamfer + rib_height])
        linear_extrude(height = height - 2 * chamfer - 2 * rib_height)
        minkowski() {
            square([
                rib_height - 2 * rib_corner_radius,
                rib_width - 2 * rib_corner_radius
            ], center = true);
            circle(r = rib_corner_radius, $fn = 12);
        }
}

module lid_ribbing(radius, height) {
    for (rib = [0 : rib_count - 1])
        rotate([0, 0, rib * 360 / rib_count])
            lid_rib(radius, height);
}

// Encircling band matching the rib's radial and vertical thickness,
// flush with the top/bottom of the ribbed section.
module lid_rib_ring(radius, z_center) {
    translate([0, 0, z_center])
        rotate_extrude()
        translate([radius, 0, 0])
        minkowski() {
            square([
                rib_height - 2 * rib_corner_radius,
                rib_width - 2 * rib_corner_radius
            ], center = true);
            circle(r = rib_corner_radius, $fn = 12);
        }
}

module lid_rib_rings(radius, height) {
    lid_rib_ring(radius, chamfer + rib_width / 2);
    lid_rib_ring(radius, height - chamfer - rib_width / 2);
}


// ============================================================
// CHAMFER CUTTER
// ============================================================
//
// Removes a 45 degree wedge from a convex outer edge at radius
// `radius` / height `z`.
//
// flip = false: material is above z (e.g. a bottom edge, or
//               the step up to a recessed neck).
// flip = true:  material is below z (e.g. a top edge).
//
// rotate_extrude() maps the polygon's X to radius and Y to Z
// directly, so the points below need no further translation.
//

module chamfer_cut(radius, z, size, flip = false) {
    dz = flip ? -size : size;
    rotate_extrude()
        polygon([
            [radius - size, z],
            [radius,        z],
            [radius,        z + dz]
        ]);
}


// ============================================================
// CONTAINER
// ============================================================

module threaded_container() {

    difference() {

        union() {

            // ------------------------------------------------
            // Main body
            // ------------------------------------------------
            //
            // Full 20 mm radius up to the start of the neck.
            //

            cylinder(
                r = outer_radius,
                h = thread_start
            );


            // ------------------------------------------------
            // RECESSED THREADED NECK
            // ------------------------------------------------
            //
            // IMPORTANT:
            // The neck starts BELOW the thread base.
            //
            // This gives the thread real supporting material.
            //

            translate([
                0,
                0,
                thread_start - thread_overlap
            ])
                cylinder(
                    r = neck_radius,
                    h = thread_length + thread_overlap + edge_pad
                );


            // ------------------------------------------------
            // EXTERNAL THREAD
            // ------------------------------------------------
            //
            // Thread base penetrates neck by thread_overlap.
            //
            // This guarantees the thread is fused to the body.
            //

            translate([
                0,
                0,
                thread_start
            ])
                external_thread(
                    radius =
                        neck_radius - thread_overlap,

                    height =
                        thread_length,

                    pitch =
                        pitch,

                    thread_height =
                        thread_height + thread_overlap,

                    thread_z =
                        thread_z
                );
        }


        // ----------------------------------------------------
        // Hollow container
        // ----------------------------------------------------
        //
        // The cavity must narrow before it reaches the neck.
        //
        // Otherwise a radius of (outer_radius - wall) would cut
        // straight through the recessed neck and thread (whose
        // max radius is smaller than that), hollowing them out
        // completely and leaving nothing thread-like outside.
        //

        translate([
            0,
            0,
            wall
        ])
            cylinder(
                r = outer_radius - wall,
                h = thread_start - wall
            );

        translate([
            0,
            0,
            thread_start - edge_pad
        ])
            cylinder(
                r = neck_radius - wall,
                h = body_height - thread_start + edge_pad
            );


        // ----------------------------------------------------
        // Chamfers
        // ----------------------------------------------------

        // Bottom outer edge of the body.
        chamfer_cut(outer_radius, 0, chamfer);

        // Top rim of the outer hull, just below the thread start,
        // where the outer wall meets the shoulder down to the neck.
        chamfer_cut(outer_radius, thread_start, chamfer, flip = true);

        // Step up to the recessed threaded neck.
        chamfer_cut(neck_radius, thread_start, chamfer);
    }
}


// ============================================================
// LID
// ============================================================

module threaded_lid() {

    // EXACT same outside radius as container.
    lid_outer_radius = outer_radius;


    difference() {

        // ----------------------------------------------------
        // Lid exterior (with grip ribbing)
        // ----------------------------------------------------

        union() {
            cylinder(
                r = lid_outer_radius,
                h = lid_height
            );

            lid_ribbing(
                radius = lid_outer_radius,
                height = lid_height
            );

            lid_rib_rings(
                radius = lid_outer_radius,
                height = lid_height
            );
        }


        // ----------------------------------------------------
        // Lid interior
        // ----------------------------------------------------
        //
        // This leaves a 2 mm outside wall.
        //

        translate([
            0,
            0,
            wall
        ])
            cylinder(
                r = lid_inner_radius,
                h = lid_height + edge_pad
            );


        // ----------------------------------------------------
        // INTERNAL THREAD
        // ----------------------------------------------------
        //
        // The cutter cuts INTO the lid wall.
        //
        // It is enlarged slightly for print clearance.
        //

        translate([
            0,
            0,
            wall - pitch * 0.20
        ])
            internal_thread(
                radius =
                    neck_radius + clearance,

                height =
                    thread_length + pitch * 0.40,

                pitch =
                    pitch,

                thread_height =
                    thread_height + clearance,

                thread_z =
                    thread_z + 0.25
            );


        // ----------------------------------------------------
        // Chamfers on the outer rim, top and bottom
        // ----------------------------------------------------

        // Radius is bumped out by edge_pad so the wedge fully
        // overlaps the ribs instead of just grazing them, which
        // left tangent-face artifacts at the rib/chamfer seam.
        chamfer_cut(lid_outer_radius + edge_pad, 0, chamfer);
        chamfer_cut(lid_outer_radius + edge_pad, lid_height, chamfer, flip = true);
    }
}


// ============================================================
// DISPLAY
// ============================================================

// Container
threaded_container();


// Lid beside container
translate([
    outer_radius * 2.5,
    0,
    0
])
    threaded_lid();
