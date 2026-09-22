// Hinged Box
//
include <BOSL2/std.scad>

/* [Box Dimensions (mm)] */
box_depth = 30; // [10:1:200]
box_width = 50; // [10:1:200]
box_height = 10; // [10:1:200]
box_corner = 3; // [1:1:10]
wall_thickness = 1.5; // [0.4:0.1:5]
hinge_radius = 5; // [1:1:20]
hinge_gap = .3; // [.1:.1:1]

/* [Hidden] */
//$preview = true;
local = 1;
$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.1;

layer_height = 0.2;
tolerance = 0.25;
epsilon = 0.05;
chamfer = 0.4;

grid_size = 5;
grid_height = 2 * layer_height;
lid_height = wall_thickness + 2 * chamfer;


// ====================================================================
// Model Parts
// ====================================================================
function grid_dim(val) = floor(val / grid_size);

module box_grid() {
    side = grid_size - wall_thickness;
    grid_count = [
        grid_dim(box_width - box_corner),
        grid_dim(box_depth - box_corner),
    ];

    grid_copies(spacing=grid_size, n=grid_count) {
        cuboid([side, side, grid_height + epsilon], anchor=TOP);
    }
}

module box_lid() {
    if (1) difference() {
        //color("lime", alpha=.4)
        offset_sweep(
            path = rect([box_width, box_depth], rounding=box_corner),
            height = lid_height,
            bottom = os_chamfer(width=wall_thickness),
            top = os_chamfer(width=chamfer),
            anchor = BOTTOM
        );

       //color("red")
       up(grid_height - epsilon)
        box_grid();
    }
}

module box_body() {
    w2 = 2 * wall_thickness;

    difference() {
        offset_sweep(
            path = rect([box_width, box_depth], rounding=box_corner),
            height = box_height,
            bottom = os_chamfer(width=chamfer),
            anchor = CENTER
        );

        up(wall_thickness + epsilon)
        offset_sweep(
            path = rect([box_width - w2, box_depth - w2], rounding=box_corner - wall_thickness),
            height = box_height,
            bottom = os_chamfer(width=-tolerance),
            anchor = CENTER
        );

        up(box_height / 2 + epsilon)
        offset_sweep(
            path = rect([box_width - chamfer, box_depth - chamfer], rounding=box_corner),
            height = wall_thickness - chamfer,
            bottom = os_chamfer(width=wall_thickness - chamfer),
            anchor = TOP
        );

        //color("red")
        down(box_height / 2 - wall_thickness - grid_height / 2 - epsilon)
        box_grid();
    }
}

module hinged_box() {
    //up(box_height) box_grid();

    if (1)
        up(2 * box_height + epsilon)
        back(box_depth / 2 - lid_height)
        xrot(-90) box_lid();
    if (1) box_body();
}

// ====================================================================
// Main Assembly & Plates
// ====================================================================

module mw_plate_1() {
    hinged_box();
}

if ($preview || local) { // main assembly in Parametric Model Maker
    mw_plate_1();
}
