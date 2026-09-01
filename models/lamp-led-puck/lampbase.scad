// Lamp base with a twist-lock bayonet mechanism.
//

include <BOSL2/std.scad>

/* [Base + Shade Dimensions] */
// Maximal diameter of the LED puck
led_puck_diameter = 82; // [25:1:120]
// Maximal height of the LED puck
led_puck_height = 21; // [10:5:40]
// Lamp base height
base_height = 40; // [1:0.5:10]
// Lamp shade height
shade_height = 90; // [30:5:200]
// Wall thickness of the lamp base and shade
wall_thickness = 2.5; // [0.5:0.25:3]
// Chamfer applied to the lamp base's top and bottom edges
lamp_chamfer = .75; // [0.5:0.25:2]
// Cable diameter for the lamp base's cable slot
cable_diameter = 3; // [1:0.5:10]
// Lug size
lug_size = 5; // [1:0.5:10]

/* [Hidden] */
//$preview = true;
local = 0;
$fa = $preview ? 16 : 1;
$fs = $preview ? 2 : 0.1;

// Compliance tolerance for parts fitting
tolerance = 0.2;
// Extra gap added to carve-out shapes
edge_gap = 0.1;
// Font family for text engraving
Font_family = "Helvetica:style=Bold";

led_insert_diameter = led_puck_diameter + 2 * (wall_thickness);
base_size = led_insert_diameter + 2 * (wall_thickness + lug_size + 2 * tolerance);
led_insert_height = led_puck_height + wall_thickness + 2 * tolerance;
lug_radius = led_insert_diameter / 2;
cable_sweep_angle = (180 / PI * 1.25 * cable_diameter / lug_radius);

echo("OUTER base diameter:", base_size);
echo("OUTER holder diameter:", led_insert_diameter);


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

// rotational extrusion of an ellipsoid with its center at `radius`
module torus(radius, rx, ry, arc=360) {
    rotate_extrude(angle=arc, convexity=2)
        translate([radius, 0, 0])
            scale([rx, ry, 1])
                circle(r=1, $fn=$fn);
}

module twist2lock() {
    if (local && 0)
        color("red") up(wall_thickness / 2 - .1 * edge_gap) yrot(180)
            linear_extrude(height=wall_thickness / 2, convexity=10)
                resize([.6 * led_insert_diameter, 0, 0], auto=[false, true, true])
                    import("./twist-lock.svg", center=true);
    else {
        for (angle=[0, 180])
        for (shift=[0, .2]) {
            color("red") zrot(angle) right(shift) fwd(shift)
            back(.2 * led_insert_diameter) up(lamp_chamfer / 2 - edge_gap / 2)
            yrot(180)
            text3d("←Open / Close→", h=lamp_chamfer, size=5, font=Font_family, anchor=CENTER);
         }
    }
}

module one_lug(radius, angle=0, arc_scale=1, slot=false) {
    lug_sweep_angle = (180 / PI * 3 * lug_size / radius + (slot ? 3 : 0)) * arc_scale;

    slot_height = lug_size + 1.75 * wall_thickness;
    points = slot ? [
        [radius - edge_gap, 0],
        [radius + lug_size, 0],
        [radius + lug_size, slot_height],
        [radius - edge_gap, slot_height]
    ] : [
        [radius, -lug_size],
        [radius + lug_size, -wall_thickness / 4],
        [radius + lug_size, wall_thickness / 4],
        [radius, lug_size]
    ];

    rotate(angle - lug_sweep_angle / arc_scale / 2)
        translate([0, 0, slot ? -edge_gap : lug_size + 2 * wall_thickness])
            rotate_extrude(angle=lug_sweep_angle, convexity=10)
                polygon(points);
}

module all_lugs(radius, arc_scale=1, slot=false) {
    for (angle = [0, 120, 240])
        one_lug(radius, angle - 30, arc_scale, slot);
}


// ====================================================================
// Objects
// ====================================================================

module led_holder() {
    twist2lock();

    solid() all_lugs(led_insert_diameter / 2);

    difference() {
        // LED insert main body
        cyl(d=led_insert_diameter, h=led_insert_height, chamfer=lamp_chamfer,
            anchor=BOTTOM);

        // LED insert cavity
        up(wall_thickness)
            cyl(d=led_insert_diameter - 2 * wall_thickness,
                h=led_insert_height + edge_gap, chamfer=lamp_chamfer,
                anchor=BOTTOM);

        // Twist finger holes
        down(edge_gap) left(.3 * led_insert_diameter)
            cyl(d=led_insert_diameter / 6,
                h=wall_thickness + 2 * edge_gap, chamfer=-lamp_chamfer,
                anchor=BOTTOM);
        down(edge_gap) right(.3 * led_insert_diameter)
            cyl(d=led_insert_diameter / 6,
                h=wall_thickness + 2 * edge_gap, chamfer=-lamp_chamfer,
                anchor=BOTTOM);

        // Cable slot main slit
        //color("yellow")
        up(2 * wall_thickness + led_insert_height / 2)
        fwd(led_insert_diameter / 2 - 3 * wall_thickness)
            up(led_insert_height / 2 - lug_size)
            xrot(90) zrot(90)
            offset_sweep(
                path = ellipse([
                    led_insert_height - .75 * lug_size,
                    cable_diameter + 3 * lug_size]),
                height = 3 * wall_thickness
            );
    }
}

module lamp_base() {
    // Base
    upper_height = base_height - led_insert_height - lug_size;

    difference() {
        // Base main body
        cyl(d=base_size, h=base_height, chamfer=lamp_chamfer,
            anchor=BOTTOM);

        // Base cavity: Chamfered lower tube
        down(lug_size + edge_gap)
            cyl(d=led_insert_diameter + 4 * tolerance,
                h=led_insert_height + 2 * lug_size + tolerance + edge_gap,
                chamfer=lug_size, anchor=BOTTOM);

        // Base cavity: Remove sharp chamfer edge
        down(edge_gap)
            cyl(d=led_insert_diameter - 1.25 * lug_size,
                h=base_height + edge_gap, anchor=BOTTOM);

        // Base cavity: Carve upper space for lamp shade
        up(base_height - upper_height - edge_gap)
            cyl(d=base_size - 2 * wall_thickness + 2 * tolerance,
                h=upper_height + 2 * edge_gap, anchor=BOTTOM);

        // Lug slots
        up(tolerance)
            all_lugs(lug_radius, arc_scale=2.25);
        down(tolerance)
            all_lugs(lug_radius, arc_scale=2.25);
        all_lugs(lug_radius, slot=true);

        // Cable slot
        rotate(-90 - cable_sweep_angle / 2)
            translate([0, 0, -edge_gap])
                rotate_extrude(angle=cable_sweep_angle, convexity=10)
                    polygon([
                        [lug_radius - edge_gap, 0],
                        [lug_radius + lug_size, 0],
                        [lug_radius + lug_size, led_insert_height - lug_size - edge_gap],
                        [lug_radius - edge_gap, led_insert_height - edge_gap]
                    ]);

        // Cable port
        //color("yellow")
        zrot(cable_sweep_angle / 3)
        down(edge_gap)
        fwd(lug_radius - lug_size)
            xrot(90) zrot(90)
            offset_sweep(
                path = [
                    [0, 0],
                    [1.25 * cable_diameter, 0],
                    [1.75 * cable_diameter, .5 * cable_diameter],
                    [1.25 * cable_diameter, 1.1 * cable_diameter],
                    [0, 1.1 * cable_diameter],
                ],
                height = 4 * lug_size
            );
    }

    // Friction ring for lamp shade
    up(base_height - upper_height / 2)
        torus(base_size / 2 - wall_thickness + tolerance, 2 * tolerance, 1.25 * lamp_chamfer);
}


// ====================================================================
// Main Assembly & Plates
// ====================================================================
if ($preview || local) { // main assembly in Parametric Model Maker
    right(.7 * base_size)
        led_holder();
    left(.7 * base_size)
        lamp_base();
}

module mw_plate_1() {
    lamp_base();
}

module mw_plate_2() {
    led_holder();
}
