// Tap Aerator Wrench
//
// A socket wrench for screwing the aerator in and out of a tap spout,
// without scratching the chrome finish like a pipe wrench would.
// A polygonal socket (hex by default) grips the aerator sleeve, a flat bar
// handle on both sides of the socket provides the torque.
// Printed socket-up, handle flat on the plate. Use PETG or better.

include <BOSL2/std.scad>

/* [Aerator] */
// Across-flats size of the aerator sleeve (measure it, then add tolerance below)
aerator_size = 22; // [14:0.1:40]
// Number of sides of the aerator sleeve (6 = hex, 8 = octagon, ...)
aerator_sides = 6; // [3:1:12]
// How deep the aerator sleeve sits in the socket
socket_depth = 10; // [5:0.5:30]

/* [Wrench] */
// Wall thickness around the socket
wall_thickness = 3; // [2:0.5:8]
// Floor thickness below the socket (also the thickness of the handle)
floor_thickness = 5; // [3:0.5:12]
// Total length of the handle bar
handle_length = 100; // [60:1:200]
// Width of the handle bar
handle_width = 14; // [8:1:30]
// Diameter of the hanging hole at the handle end (0 = none)
hanging_hole_diameter = 6; // [0:0.5:12]
// Rounding of the handle edges
handle_rounding = 2; // [0.5:0.5:4]
// Lead-in chamfer at the socket opening
lead_in = 1; // [0.4:0.2:2]

/* [Hidden] */
//$preview = true;
local = 1;
$fa = $preview ? 32 : 4;
$fs = $preview ? 4 : 0.2;

// Clearance added to the socket so the aerator fits
tolerance = 0.2;
// Extra size added to carve-out shapes
epsilon = 0.05;

// Keep derived calculations below this line,
// so they are hidden from the user interface

// Socket apothem (inner radius to the flats) incl. clearance
socket_ir = aerator_size / 2 + tolerance;
// Socket circumradius (to the corners)
socket_corner_r = socket_ir / cos(180 / aerator_sides);
socket_od = 2 * (socket_corner_r + wall_thickness);
total_height = floor_thickness + socket_depth;
// Position of the hanging hole, centered in the handle end
hanging_hole_x = handle_length / 2 - 3 * wall_thickness;

handle_shift = .15 * handle_length;
wall_chamfer = wall_thickness / 3;


echo("SOCKET OD × HEIGHT:", socket_od, total_height);
echo("HANDLE LENGTH × WIDTH × THICKNESS:", handle_length, handle_width, floor_thickness);

// ====================================================================
// Helpers
// ====================================================================

module see_through(base_color="lime", alpha=0.5) {
    if ($preview) {
        color(base_color, alpha=alpha)
            children();
    } else {
        children();
    }
}

module solid(base_color="red") {
    if ($preview) {
        color(base_color)
            children();
    } else {
        children();
    }
}

// ====================================================================
// Parts
// ====================================================================

// Cylindrical body around the socket
module socket_body() {
    see_through()
    cyl(d=socket_od, h=total_height, chamfer=wall_chamfer, anchor=BOTTOM);
}

// Flat bar through the socket, giving leverage on both sides
module handle() {
    see_through()
    left(handle_shift) up(epsilon / 2)
    intersection() {
        cuboid([handle_length, handle_width, floor_thickness],
               rounding=handle_rounding, except=[TOP, BOTTOM], anchor=BOTTOM);
        scale(1.005)
        cuboid([handle_length, handle_width, floor_thickness],
               chamfer=wall_chamfer, edges=[TOP, BOTTOM], anchor=BOTTOM);
    }
}

// Hole to hang the wrench up, through the handle only
module hanging_hole() {
    solid()
    right(hanging_hole_x - handle_shift) down(epsilon)
        cyl(d=hanging_hole_diameter, h=floor_thickness + 2 * epsilon, chamfer=-wall_chamfer, anchor=BOTTOM);
}

// Polygonal cavity gripping the aerator, with a lead-in chamfer
module socket_cavity() {
    solid()
    up(floor_thickness) {
        regular_prism(aerator_sides, h=socket_depth + epsilon, ir=socket_ir, anchor=BOTTOM);

        up(socket_depth - lead_in)
            regular_prism(aerator_sides, h=lead_in + epsilon, ir1=socket_ir, ir2=socket_ir + lead_in + epsilon,
                          anchor=BOTTOM);
    }
}

// ====================================================================
// Main Assembly & Plates
// ====================================================================

module wrench() {
    difference() {
        union() {
            socket_body();
            handle();
        }
        socket_cavity();
        if (hanging_hole_diameter > 0)
            hanging_hole();
    }
}

// ====================================================================
// Plates
// ====================================================================

module assembly() {
    wrench();
}

// The socket opens upwards and the handle lies flat on the plate
module mw_plate_1() {
    wrench();
}

if ($preview || local) { // main assembly in Parametric Model Maker
    if ($preview) mw_plate_1();
    else assembly();
}
