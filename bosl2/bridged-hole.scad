// Cuboid with a hexagonal nut pocket at the bottom and a smaller screw hole on top.
//
// The pocket roof is closed by a stack of one-layer-thick bridging planes: each layer's
// opening is the hexagon cut by straight-edged strips (rectangles) at several angles, i.e. a
// many-sided polygon. All strips narrow together on every layer, so each edge only bridges a
// small step beyond the layer below and no void is left under a later layer.
// This prints without supports and without a long, unsupported bridge.

include <BOSL2/std.scad>

/* [Block] */
// Block width (X)
block_width = 12; // [10:1:60]
// Block length (Y)
block_length = 12; // [10:1:60]
// Block height (Z)
block_height = 8; // [8:1:60]
// Chamfer on all block edges
chamfer = 0.6; // [0:0.2:2]

/* [Screw and Nut] */
// Screw shank diameter (M3 = 3)
screw_diameter = 3; // [2:0.1:8]
// Nut width across the flats (M3 = 5.5)
nut_width = 5.5; // [3:0.1:14]
// Nut thickness (M3 = 2.4)
nut_thickness = 2.4; // [1:0.1:8]

/* [Printing] */
// Printer layer height; bridging planes are one layer thick
layer_height = 0.2; // [0.08:0.04:0.4]
// Maximum the strip half-width may shrink per layer
bridge_step = 0.3; // [0.1:0.05:1.5]
// Number of different strip angles (the opening has twice as many sides)
bridge_angles = 6; // [2:1:12]
// Cut the block in half to show the bridging stack
cutaway = true;

/* [Hidden] */
$fa = $preview ? 8 : 2;
$fs = $preview ? .6 : 0.2;

// Clearance added around the screw and nut
tolerance = 0.2;
// Extra size added to carve-out shapes
edge_pad = 0.05;

// Pocket cross-section, flats facing along X, corners along Y
pocket_flats = nut_width + tolerance;
pocket_corners = pocket_flats / cos(30);
hole_d = screw_diameter + tolerance;
// Pocket depth, snapped to whole layers
pocket_depth = ceil((nut_thickness + tolerance) / layer_height) * layer_height;
// Strip half-width at the start (nut flats) and at the end (screw hole)
width_start = pocket_flats / 2;
width_end = hole_d / 2;
// Bridge layers needed to narrow the strips down to the screw hole
bridge_layers = ceil((width_start - width_end) / bridge_step);
// Strips are evenly spread over 180 degrees
function strip_angle(i) = i * 180 / bridge_angles;
// Strip half-width on layer k
function strip_halfwidth(k) = width_start - (width_start - width_end) * (k + 1) / bridge_layers;

echo("POCKET DEPTH:", pocket_depth, "BRIDGE LAYERS:", bridge_layers);


// ====================================================================
// Helpers
// ====================================================================

module see_through(base_color="grey", alpha=0.6) {
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

module nut_pocket() {
    zrot(90) cyl(d=pocket_corners, h=pocket_depth + edge_pad, $fn=6, anchor=BOTTOM);
}

// Bridge k: the part of the hexagon outside the polygon of layer k. It starts at its own layer
// and is extruded up to the top of the stack, so later bridges never span gaps left by earlier ones.
module bridge(k) {
    up(pocket_depth + k * layer_height)
        linear_extrude(bridge_layers * layer_height - k * layer_height + edge_pad)
            difference() {
                rotate(90) regular_ngon(n=6, d=pocket_corners + 2 * edge_pad);
                bridge_opening(k);
            }
}

// Opening of layer k: all strips of that layer intersected
module bridge_opening(k) {
    intersection_for (i = [0:bridge_angles - 1])
        rotate(strip_angle(i)) rect([4 * pocket_corners, 2 * strip_halfwidth(k)]);
}

// The hexagonal pocket and the room above it, minus all the bridges
module nut_cavity() {
    difference() {
        union() {
            nut_pocket();
            up(pocket_depth - edge_pad)
                linear_extrude(bridge_layers * layer_height + edge_pad)
                    rotate(90) regular_ngon(n=6, d=pocket_corners);
        }
        for (k = [0:bridge_layers - 1]) bridge(k);
    }
}

module screw_hole() {
    cyl(d=hole_d, h=block_height + 2 * edge_pad, anchor=BOTTOM);
}

module cavity() {
    down(edge_pad) nut_cavity();
    down(edge_pad) screw_hole();
    if (cutaway)
        down(edge_pad) cuboid([block_width, block_length / 2 + edge_pad, block_height + 1], anchor=BOTTOM + BACK);
}


// ====================================================================
// Assembly
// ====================================================================

module assembly() {
    if ($preview) solid() cavity();
    difference() {
        see_through("lime", alpha=.3)
            cuboid([block_width, block_length, block_height], chamfer=chamfer, anchor=BOTTOM);
        cavity();
    }
}

assembly();
