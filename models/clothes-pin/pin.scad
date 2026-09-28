// Clothes Pin
//
include <BOSL2/std.scad>

/* [PinDimensions (mm)] */
pin_depth = 15; // [10:1:40]
pin_width = 25; // [10:1:40]
pin_gap = .6; // [.2:.05:1]

/* [Hidden] */
//$preview = true;
local = 1;

$fa = $preview ? 16 : 2;
$fs = $preview ? 2 : 0.2;

filament_diameter = 1.75;
layer_height = 0.2;
tolerance = 0.25;
epsilon = 0.05;
chamfer = 0.75;

eps2 = 2 * epsilon;
t2 = 2 * tolerance;

svg_file = "Clothes-Pin.svg";
// grip_tex = "dots";
grip_tex = "wave_ribs";
//grip_tex = "hills";
pin_length_approx = 36;


function grid_dim(val) = floor(val / grid_size);
function eps(dim) = (dim + epsilon) / dim;
function tol(dim) = (dim + tolerance) / dim;

module see_through(base_color="grey") {
    if ($preview) {
        color(base_color, 0.6)
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

// right-triangle cross-section (90° angle at the top apex), extruded along length
module chamfer_cutter(length) {
    amp = 1.5;

    xrot(90)
    linear_extrude(height = length, center = true, convexity = 10)
        polygon(points = [
            [0, amp * chamfer],
            [-amp * chamfer, 0],
            [amp * chamfer, 0],
        ]);
}

module rift_cutter(height, gap, length) {
    freq = 2.5;

    for (dir = [1, -1])
    xrot(90)
    right(dir * gap / 2)
    up(dir * freq * gap / 4)
    yrot(dir * 90)
    textured_tile(size = [length, height, gap / 2 + epsilon],
        texture = "wave_ribs",
        tex_size = [freq * gap, freq * gap],
        tex_depth = gap / 2,
        tex_inset = false);
}

module grip_cutter(height, size) {
    cyl(h = height + 2 * tolerance, d = size,
        texture = grip_tex,
        tex_size = [3 * chamfer, 2 * chamfer],
        tex_depth = -tolerance,
        tex_inset = false,
        chamfer = -chamfer);
}

// ====================================================================
// Main Model
// ====================================================================
module half_shape() {
    resize([pin_width / 2, 0, 0], auto = [false, true, true])
        import(svg_file, center = true);
}

module cross_section() {
    union() {
        half_shape();

        left(pin_width / 2 - tolerance)
        mirror([1, 0, 0])
            half_shape();
    }
}

// a diamond (two cones tip to tip): minkowski with this bevels top/bottom edges
// without collapsing the concave cross_section the way hull() would
module chamfer_tool() {
    union() {
        cylinder(h = chamfer, r1 = chamfer, r2 = 0);
        mirror([0, 0, 1])
            cylinder(h = chamfer, r1 = chamfer, r2 = 0);
    }
}

module pin_body() {
    difference() {
        right(pin_width / 4)
        minkowski($fn=$preview ? 8 : 32) {
            linear_extrude(height = pin_depth - 2 * chamfer, center = true, convexity = 10)
                offset(r = -chamfer)
                    cross_section();

            chamfer_tool();
        };

        solid()
        fwd(.4 * pin_length_approx)
        down(pin_depth / 2 + epsilon)
        chamfer_cutter(pin_length_approx / 3);

        solid()
        fwd(.4 * pin_length_approx)
        up(pin_depth / 2 + epsilon) yrot(180)
        chamfer_cutter(pin_length_approx / 3);

        for (dir = [1, -1])
            solid()
            back(.16 * pin_length_approx)
            left(.86 * pin_width * dir)
            grip_cutter(pin_depth, pin_width);

        solid()
        fwd(.4 * pin_length_approx)
        rift_cutter(pin_depth, pin_gap / 3, pin_length_approx / 3);
    }
}

// ====================================================================
// Main Assembly & Plates
// ====================================================================

// inside hinges
module mw_plate_1() {
    pin_body();
}

if ($preview || local) { // main assembly in Parametric Model Maker
    mw_plate_1();
}
