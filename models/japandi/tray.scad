// Japandi Tray

include <BOSL2/std.scad>

/* [Main Settings] */
// Outer width of the tray
width = 100; // [40:1:200]
// Outer length of the tray
length = 190; // [40:1:200]
// Total height of the tray
height = 20; // [40:1:200]
// Height of upper rim
rim_height = 5; // [0:1:200]
// Radius of the ribs around the main body
rib_radius = 1; // [0.25:0.25:9]

// Wall thickness of the holder
wall_thickness = 1.5; // [1.25:0.25:10]
// Floor thickness below the fillet
floor_thickness = 2.5; // [1:0.2:10]
// Radius of the fillet between inner floor and inner wall
floor_fillet = 4; // [0.4:0.2:30]

/* [Edges] */
// Rounding of the outer bottom edge
bottom_rounding = 1.25; // [0:0.25:10]

/* [Hidden] */
//$preview = true;
local = 1;
$fa = $preview ? 24 : 4;
$fs = $preview ? 2 : 0.2;

// Keep derived calculations below this line,
// so they are hidden from the user interface

body_width = width - 2 * rib_radius;
body_length = length - 2 * rib_radius;
inner_width = body_width - 2 * wall_thickness;
inner_length = body_length - 2 * wall_thickness;
corner_radius = min(body_width, body_length) / 10;
inner_corner_radius = max(0, corner_radius - wall_thickness);
inner_height = height - floor_thickness;
// The fillet cannot exceed either inner footprint dimension or the cavity height
safe_fillet = min(floor_fillet, inner_width / 2 - 0.1, inner_length / 2 - 0.1, inner_height - 0.1);

echo("SIZE H × W × L:", height, width, length);
echo("INNER W × L:", inner_width, inner_length);

// ====================================================================
// Parts
// ====================================================================

module ribs() {
    width_span = body_width - 2 * corner_radius;
    length_span = body_length - 2 * corner_radius;
    width_rib_count = max(1, floor(width_span / (2 * rib_radius)));
    length_rib_count = max(1, floor(length_span / (2 * rib_radius)));
    width_rib_spacing = width_span / width_rib_count;
    length_rib_spacing = length_span / length_rib_count;
    corner_rib_count = max(1, floor(PI * corner_radius / (4 * rib_radius)));
    corner_rib_spacing = 90 / corner_rib_count;

    intersection() {
        union() {
            for (i = [0:width_rib_count - 1]) {
                x = -width_span / 2 + (i + 0.5) * width_rib_spacing;
                for (side = [-1, 1])
                    translate([x, side * body_length / 2, 0])
                        cyl(h=height - rim_height, r=rib_radius, anchor=BOTTOM);
            }

            for (i = [0:length_rib_count - 1]) {
                y = -length_span / 2 + (i + 0.5) * length_rib_spacing;
                for (side = [-1, 1])
                    translate([side * body_width / 2, y, 0])
                        cyl(h=height - rim_height, r=rib_radius, anchor=BOTTOM);
            }

            for (x_side = [-1, 1], y_side = [-1, 1], i = [0:corner_rib_count - 1]) {
                angle = (i + 0.5) * corner_rib_spacing;
                x = x_side * (body_width / 2 - corner_radius + corner_radius * cos(angle));
                y = y_side * (body_length / 2 - corner_radius + corner_radius * sin(angle));
                translate([x, y, 0])
                    cyl(h=height - rim_height, r=rib_radius, anchor=BOTTOM);
            }
        }

        offset_sweep(
            path=rect([body_width + 2 * rib_radius, body_length + 2 * rib_radius],
                rounding=corner_radius + rib_radius),
            height=height - rim_height,
            bottom=os_chamfer(bottom_rounding + rib_radius),
            anchor="base"
        );
    }
}

// Rounded rectangular body with a wider upper rim
module body() {
    color("#aaa")
    offset_sweep(
        path=rect([body_width, body_length], rounding=corner_radius),
        height=height - rim_height,
        bottom=os_chamfer(bottom_rounding),
        anchor="base"
    );

    color("#aaa")
        ribs();

    // Upper rim
    color($preview ? "red" : "black")
    up(height - rim_height)
    offset_sweep(
        path=rect([width, length],
            rounding=corner_radius + rib_radius),
        height=rim_height,
        bottom=os_circle(r=wall_thickness / 3),
        top=os_circle(wall_thickness / 3),
        anchor="base"
    );
}

// Cavity with a filleted transition between the floor and walls
module cavity() {
    up(floor_thickness)
    offset_sweep(
        path=rect([inner_width, inner_length], rounding=inner_corner_radius),
        height=inner_height + 1,
        bottom=os_circle(r=safe_fillet),
        top=os_circle(r=-wall_thickness / 4),
        anchor="base"
    );
}

// ====================================================================
// Main Assembly
// ====================================================================

module tray() {
    difference() {
        body();
        cavity();
    }
}

// ====================================================================
// Plates
// ====================================================================

module assembly() {
    back_half(length + width) mw_plate_1();
}

module mw_plate_1() {
    zrot(-90)
    tray();
}

if ($preview || local) {
    if ($preview) assembly();
    else mw_plate_1();
}
