include <BOSL2/std.scad>

// Over-center snap hinge, derived from assets/over-center-sketch.png.
// A flat body plate with a hub at the left and an open (C-shaped) socket at
// the right. A link swings around the hub pin; its end pin snaps over the
// center of the socket opening and is held there by the over-center geometry.

/* [Sketch dimensions] */
// Distance from the hub axis to the right edge of the body
overall_x = 33.5; // [10:0.1:80]
// Plate thickness of the body (and pin height)
plate_t = 2.75; // [1:0.05:10]
// Hole diameter of the hub (left pivot)
hub_hole_d = 3.4; // [1:0.1:10]
// Hole diameter of the socket (right pivot)
socket_d = 3.0; // [1:0.1:10]
// Diameter of the rounded lower corner
corner_d = 2.5; // [1:0.1:10]
// Wall between the socket and the right edge
socket_wall = 2; // [0.5:0.1:6]
// Angle of the lower body edge relative to the top edge
slope_angle = 7; // [0:0.5:20]
// Height of the body above the hub axis (also the hub radius)
body_top = 4.7; // [2:0.1:20]
// Offset of the socket axis above the hub axis
socket_dy = 0.5; // [-3:0.1:3]
// Offset of the lower corner center below the hub axis
corner_dy = 1.1; // [0:0.1:5]

/* [Link] */
// Swing angle of the link around the hub (0 = snapped into the socket)
link_angle = 0; // [0:1:90]
// Width of the link bar
link_w = 5; // [3:0.5:12]
// Thickness of the link bar
link_t = 2; // [1:0.1:6]
// Radial clearance between pins and their holes
pin_clearance = 0.05; // [0:0.01:0.5]
// Gap between the link and the body plate
layer_gap = 0.3; // [0:0.05:1]

/* [Display] */
// Show the printable layout instead of the assembly
print_layout = false;

/* [Hidden] */
//$preview = true;
$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.1;

epsilon = 0.05;

hub_r = body_top;
socket_r = socket_d / 2;
corner_r = corner_d / 2;
socket_c = [overall_x - socket_wall - socket_r, socket_dy];
corner_c = [overall_x - corner_r, -corner_dy];
pin_d = socket_d - 2 * pin_clearance;
axle_d = hub_hole_d - 2 * pin_clearance;
link_len = norm(socket_c);
link_rot = atan2(socket_c.y, socket_c.x);

assert(slope_angle >= 0, "slope_angle must not be negative");
assert(socket_c.x > hub_r, "socket must lie beyond the hub");

// --------------------------------------------------------------------------
// --- 2D profiles

// Body outline: hub, top edge, right edge, rounded corner, and a lower edge
// running at slope_angle up to the top of the socket circle.
module body_2d() {
    top = socket_c + [0, socket_r];
    // Lower edge extended back to the hub axis; its tail lies inside the hub
    tail = [0, top.y - tan(slope_angle) * top.x];

    difference() {
        union() {
            circle(r=hub_r);
            polygon([
                tail,
                [0, body_top],
                [overall_x, body_top],
                [overall_x, corner_c.y],
                corner_c,
                socket_c,
                top,
            ]);
            translate(corner_c) circle(r=corner_r);
        }
        circle(d=hub_hole_d);
        translate(socket_c) circle(r=socket_r);
    }
}

module link_2d() {
    hull() {
        circle(d=link_w);
        translate([link_len, 0]) circle(d=link_w);
    }
}

// --------------------------------------------------------------------------
// --- 3D features

module body() {
    color("lightsteelblue")
        linear_extrude(height=plate_t)
            body_2d();
}

// Link lying in the XY plane, hub axis at the origin, +X towards the socket
module link() {
    color("orange") {
        linear_extrude(height=link_t) link_2d();
        // Pins stand on the link and pass through / into the body plate
        pin_h = link_t + layer_gap + plate_t;
        cyl(d=axle_d, h=pin_h, anchor=BOTTOM, chamfer2=pin_clearance + 0.2);
        right(link_len)
            cyl(d=pin_d, h=pin_h, anchor=BOTTOM, chamfer2=pin_clearance + 0.2);
    }
}

// --------------------------------------------------------------------------
// --- Assembly

module assembly() {
    // The link sits below the body and swings around the hub axis
    zrot(link_rot + link_angle) link();
    up(link_t + layer_gap) body();
}

module printable() {
    // Both parts lie flat on the print plate with the pins pointing up
    body();
    fwd(hub_r + link_w / 2 + 5) link();
}

if (print_layout)
    printable();
else
    assembly();
