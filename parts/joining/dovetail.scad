// Dovetail cutter applicable to any wall thick enough to contain the dovetail shape
include <BOSL2/std.scad>

/* [Bracket Dimensions (mm)] */
object_thickness = 15; // [3:1:5]
dovetail_depth = 5; // [10:1:30]
dovetail_gap = .6; // [.1:.1:1]

/* [Hidden] */
//$preview = true;
local = 1;
$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.1;

layer_height = 0.2;
tolerance = 0.25;
epsilon = 0.05;
chamfer = 0.3;

dove_thickness = 2 * dovetail_depth + object_thickness;


// Generates an open 2D path with the dovetail shape
function dovetail_flanged_wall_path(width=dovetail_depth / 4, depth=dovetail_depth, angle=45, flange_width=object_thickness, tolerance=tolerance) =
    let(
        w_neck = width + (2 * tolerance),
        w_base = w_neck + (2 * depth),

        // Coordinates for the flanged track running along the face and into the socket:
        p1 = [-w_neck/2 - flange_width, 0], // Far Left Flange (on the face)
        p2 = [-w_neck/2, 0],                // Left Neck Entry
        p3 = [-w_base/2, -depth],           // Deep Left Base
        p4 = [ w_base/2, -depth],           // Deep Right Base
        p5 = [ w_neck/2, 0],                // Right Neck Entry
        p6 = [ w_neck/2 + flange_width, 0]  // Far Right Flange (on the face)
    )
    [p1, p2, p3, p4, p5, p6];

module dovetail_cutter(flange = object_thickness) {
    dt_path = dovetail_flanged_wall_path(flange_width=flange);
    smooth_path = round_corners(dt_path, radius=1.5 * chamfer, closed=false);
    linear_extrude(height=3 * object_thickness + tolerance, center=true)
        stroke(smooth_path, width=dovetail_gap, closed=false);
}

module main_body() {
    difference() {
        //color("lime", alpha=.3)
        cuboid([object_thickness, object_thickness * 3, object_thickness * 3], chamfer = chamfer);

        zrot(180) dovetail_cutter();
    }
}


// ====================================================================
// Main Assembly & Plates
// ====================================================================

module mw_plate_1() {
    main_body();
}

if ($preview || local) { // main assembly in Parametric Model Maker
    mw_plate_1();
}
