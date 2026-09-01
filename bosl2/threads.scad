// Flush Threaded Container + Lid
//
// A container whose threaded neck is recessed below the body's outer
// wall, so a same-diameter lid screws on flush with the body. Built
// with BOSL2's trapezoidal_threaded_rod() for both the male neck
// thread and the lid's internal thread mask.

include <BOSL2/std.scad>
include <BOSL2/threading.scad>

/* [Main Settings] */
// Outside radius of the container body and lid.
outer_radius = 20; // [10:1:40]
// Wall thickness of the container and lid.
wall = 2; // [1:0.5:5]
// Height of the container body.
body_height = 30; // [15:1:80]
// Height of the lid.
lid_height = 12; // [8:1:40]
// Leg length of the 45 degree chamfer applied to sharp outer edges.
chamfer = 1; // [0.5:0.1:3]

/* [Thread] */
// Thread pitch (axial distance per turn).
pitch = 3; // [1:0.5:6]
// Number of thread turns.
thread_turns = 2.5; // [1:0.5:6]
// Radial depth of the thread.
thread_depth = 2; // [0.5:0.1:4]
// Angle between the two thread faces.
thread_angle = 30; // [15:5:60]

/* [Lid Grip] */
// Number of vertical grip ribs around the lid.
rib_count = 72; // [12:1:120]
// Radial protrusion of the grip ribs.
rib_depth = 0.6; // [0.2:0.1:1.5]

/* [Preview] */
// Show the lid flipped and threaded onto the container instead of the print layout.
show_assembled = false;

/* [Hidden] */
$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.1;

// Printer-specific slop; widens the lid's internal thread cut by 4*$slop.
$slop = 0.15;

// Overlap between stacked pieces, to avoid coincident-plane CSG artifacts.
edge_pad = 0.05;

// Lid's usable inside radius, limited by its own wall.
lid_inner_radius = outer_radius - wall;

// Thread crest stays just inside the lid wall so it mates flush.
thread_crest_radius = lid_inner_radius - 0.2;
thread_diam = 2 * thread_crest_radius;

// Root radius of the thread; the neck below it is recessed to this size.
neck_radius = thread_crest_radius - thread_depth;

thread_length = pitch * thread_turns;
thread_start = body_height - thread_length;


// ============================================================
// SHARED THREAD PROFILE
// ============================================================

// Same nominal thread on both parts; internal=true auto-enlarges via $slop.
module std_thread(l, internal = false, bevel1 = false, bevel2 = false, anchor = BOTTOM) {
    trapezoidal_threaded_rod(
        d = thread_diam, l = l, pitch = pitch,
        thread_depth = thread_depth, thread_angle = thread_angle,
        internal = internal, bevel1 = bevel1, bevel2 = bevel2,
        anchor = anchor
    );
}


// ============================================================
// CONTAINER
// ============================================================

module threaded_container() {
    difference() {
        union() {
            cyl(r = outer_radius, h = thread_start, anchor = BOTTOM, chamfer1 = chamfer);

            // Shoulder stepping down to the recessed threaded neck.
            up(thread_start - edge_pad)
                cyl(r1 = outer_radius, r2 = neck_radius, h = chamfer + edge_pad, anchor = BOTTOM);

            up(thread_start + chamfer - edge_pad)
                std_thread(l = thread_length - chamfer + edge_pad, bevel2 = true);
        }

        // Hollow interior; narrows under the neck so it doesn't hollow out the thread.
        up(wall)
            cyl(r = outer_radius - wall, h = thread_start - wall, anchor = BOTTOM);
        up(thread_start - edge_pad)
            cyl(r = neck_radius - wall, h = thread_length + edge_pad, anchor = BOTTOM, extra2 = 1);
    }
}


// ============================================================
// LID
// ============================================================

module threaded_lid() {
    difference() {
        // EXACT same outside radius as the container, with knurled grip ribs.
        // tex_inset keeps the rib peaks at outer_radius, so the OD stays flush.
        cyl(
            r = outer_radius, h = lid_height, anchor = BOTTOM,
            chamfer1 = chamfer, chamfer2 = chamfer,
            texture = "trunc_ribs", tex_reps = [rib_count, 1],
            tex_depth = rib_depth, tex_inset = true, tex_taper = 2 * chamfer / lid_height
        );

        // Internal thread, recessed at the opening (top when printed).
        up(lid_height - thread_length + edge_pad)
            std_thread(l = thread_length, internal = true, bevel2 = true);

        // Interior bore, open at the top.
        up(wall)
            cyl(r = lid_inner_radius - wall, h = lid_height, anchor = BOTTOM, extra2 = 1);
    }
}


// ============================================================
// DISPLAY
// ============================================================

if (show_assembled) {
    // The lid is printed opening-up, so capping the container flips it
    // 180 degrees; its rim then lands right on the neck's shoulder.
    threaded_container();

    up(thread_start + lid_height)
        xrot(180)
            threaded_lid();
} else {
    // Print layout: both parts right-side up, as oriented on the plate.
    threaded_container();

    right(outer_radius * 2.5)
        threaded_lid();
}
