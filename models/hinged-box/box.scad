// Hinged Box
//
include <BOSL2/std.scad>

/* [Box Dimensions (mm)] */
box_depth = 30; // [10:1:200]
box_width = 45; // [10:1:200]
box_height = 15; // [10:1:200]
box_corner = 3; // [1:1:10]
wall_thickness = 2; // [0.4:0.1:5]

/* [Hidden] */
//$preview = true;
local = 1;
$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.1;

filament_diameter = 1.75;
layer_height = 0.2;
tolerance = 0.25;
epsilon = 0.05;
chamfer = 0.4;

eps2 = 2 * epsilon;
t2 = 2 * tolerance;
w2 = 2 * wall_thickness;

grid_size = 5;
grid_height = 2 * layer_height;
lid_height = 4 * wall_thickness + chamfer;

hinge_gap = tolerance;
hinge_width_target = 5;
n = floor((box_width - 2 * box_corner) / (hinge_width_target + hinge_gap) / 2) * 2;
hinge_width = (box_width - 2 * box_corner - (n - 1) * hinge_gap) / n;
hinge_spacing = hinge_width + hinge_gap;


// ====================================================================
// Model Parts
// ====================================================================
function grid_dim(val) = floor(val / grid_size);
function eps(dim) = (dim + epsilon) / dim;
function tol(dim) = (dim + tolerance) / dim;

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

module snap_lock() {
    size = wall_thickness;

    color("red")
    back(wall_thickness - t2) up(size)
    xrot(180)
    cuboid([box_width - 2 * box_corner - t2, .25 * size, .5 * size],
           rounding=.125 * size, edges=[TOP+FRONT, TOP+BACK], anchor=BOTTOM);
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

    fwd(box_depth / 2 - .4 * tolerance)
    up(wall_thickness - tolerance)
    xrot(-90)
    snap_lock();
}

module box_body() {
    difference() {
        // Rounded body block
        offset_sweep(
            path = rect([box_width, box_depth], rounding=box_corner),
            height = box_height,
            bottom = os_chamfer(width=chamfer),
            anchor = CENTER
        );

        // Main cavity
        up(wall_thickness + epsilon)
        offset_sweep(
            path = rect([box_width - w2, box_depth - w2], rounding=box_corner - wall_thickness),
            height = box_height,
            bottom = os_chamfer(width=-tolerance),
            anchor = CENTER
        );

        // Upper chamfer
        up(box_height / 2 + epsilon)
        offset_sweep(
            path = rect([box_width - chamfer, box_depth - chamfer], rounding=box_corner),
            height = wall_thickness - chamfer,
            bottom = os_chamfer(width=wall_thickness - chamfer),
            anchor = TOP
        );

        // Groove for snap locking
        //right(box_width / 2)
        up(box_height / 2 + wall_thickness / 6)
        fwd(box_depth / 2 - .0 * wall_thickness + epsilon)
        xrot(-90) scale(1.05)
            snap_lock();
    }

    
    // Shrink relieve (anti-hull line)
    // TODO: Use inverted chamfer instead!
    color("red")
    down(box_height / 2 - wall_thickness - grid_height + epsilon)
    box_grid();
}

module hinge_row() {
    grid_copies(spacing=2 * hinge_spacing, n=[n / 2, 1]) {
        difference() {
            //color("red")
            cuboid([hinge_width, 3*wall_thickness, 5 * wall_thickness], rounding=wall_thickness, edges=[TOP+FRONT, TOP+BACK]);

            up(wall_thickness)
            xcyl(d=filament_diameter + tolerance, h=hinge_width + epsilon, chamfer=-eps2);
        }
    }
}

module end_cap() {
    up(chamfer - tolerance)
    cyl(d1=filament_diameter + 2 * tolerance,
        d2=filament_diameter + tolerance - eps2,
        h=hinge_width / 3, chamfer=tolerance, anchor=BOTTOM);
    cyl(d=w2, h=chamfer, chamfer=eps2, anchor=BOTTOM);
}

module hinged_box() {
    // Lid
    if (1) back(1.5 * box_depth) up((box_depth - box_height) / 2) xrot(90)
    union() {
        up(box_height / 2 - wall_thickness / 2 + epsilon)
        box_lid();

        up(box_height / 2 + 2.5 * wall_thickness - 2 * chamfer - eps2) right(hinge_spacing / 2)
        back(box_depth / 2) xrot(-90)
        hinge_row();
    }

    // Main box
    if (1) box_body();

    // Hinges
    sup_size = 3 * wall_thickness + tolerance;

    up(box_height / 2) left(hinge_spacing / 2)
    back(box_depth / 2 + wall_thickness + 1.75 * chamfer)
    union() {
        // Box hinges
        difference() {
            back(tolerance)
            hinge_row();

            down(wall_thickness + 4 * chamfer) back(wall_thickness / 2 + tolerance)
            yrot(-90)
            offset_sweep(
                path = [[0, 0],
                        [0, -sup_size],
                        [sup_size, 0]],
                height = box_width - 2 * box_corner,
                anchor = CENTER
            );
        }

        // Triangular support beam for clean printing
        down(4 * chamfer + 2 * tolerance - epsilon) fwd(2 * chamfer) right(box_corner + epsilon)
        yrot(-90)
        offset_sweep(
            path = [[0, 0], [-sup_size, 0], [0, sup_size]],
            height = box_width - 2 * box_corner - eps2,
            ends = os_chamfer(width = eps2),
            anchor = CENTER
        );
    }
}

// ====================================================================
// Main Assembly & Plates
// ====================================================================

// inside hinges
module mw_plate_1() {
    hinged_box();

    if (0) fwd(.8 * box_depth) down(box_height / 2)
    grid_copies(spacing=hinge_width, n=[3, 1]) {
        end_cap();
    }
}

if ($preview || local) { // main assembly in Parametric Model Maker
    mw_plate_1();
}
