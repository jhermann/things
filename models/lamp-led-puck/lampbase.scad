// Lamp base with a twist-lock bayonet mechanism.
//

include <BOSL2/std.scad>

/* [Base + Shade Dimensions] */
// Lamp base outer diameter
base_size = 90; // [5:1:40]
// Lamp base height
base_height = 35; // [1:0.5:10]
// Lamp shade height
shade_height = 90; // [30:5:200]
// wall thickness of the lamp base and shade
wall_thickness = 2; // [0.5:0.25:3]
// Chamfer applied to the lamp base's top and bottom edges
lamp_chamfer = .75; // [0.5:0.25:2]
// Cable diameter for the lamp base's cable slot
cable_diameter = 5; // [1:0.5:10]
// Lug size
lug_size = 5; // [1:0.5:10]

/* [Hidden] */
//$preview = true;
$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.1;

// Compliance tolerance for parts fitting
tolerance = 0.2;
// Extra gap added to carve-out shapes
edge_gap = 0.1;


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

    rotate(angle)
        translate([0, 0, slot ? -edge_gap : lug_size + 2 * wall_thickness])
            rotate_extrude(angle=lug_sweep_angle, convexity=10)
                polygon(points);
}

module all_lugs(radius, arc_scale=1, slot=false) {
    for (angle = [0, 90, 180, 270])
        one_lug(radius, angle + 45, arc_scale, slot);
}

module led_holder() {
    // LED Insert
    led_insert_height = base_height - 2 * wall_thickness - lug_size;
    led_insert_diameter = base_size - 2 * wall_thickness - 2 * tolerance;

    color("red") up(wall_thickness / 2 - .1 * edge_gap) yrot(180)
        linear_extrude(height=wall_thickness / 2, convexity=10)
            resize([.6 * led_insert_diameter, 0, 0], auto=[false, true, true])
                import("./twist-lock.svg", center=true);

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
        up(2 * wall_thickness + led_insert_height / 2)
        fwd(led_insert_diameter / 2 - wall_thickness / 2 - edge_gap)
            xrot(90) zrot(90)
            cuboid([led_insert_height, cable_diameter + 2 * tolerance,
                    wall_thickness + 2 * edge_gap],
                    chamfer=-lamp_chamfer);
    }
}

module lamp_base() {
    // Base
    difference() {
        // Base main body
        cyl(d=base_size, h=base_height, chamfer=lamp_chamfer,
            anchor=BOTTOM);

        // Base cavity: Chamfered lower tube
        down(6 * lug_size + edge_gap)
            cyl(d=base_size - 4 * lug_size,
                h=base_height + 4 * lug_size + 2 * edge_gap,
                chamfer=lug_size, anchor=BOTTOM);

        // Base cavity: Remove sharp chamfer edge
        down(edge_gap)
            cyl(d=base_size - 2 * wall_thickness + 2 * tolerance - 4 * lug_size,
                h=base_height + edge_gap, anchor=BOTTOM);

        // Base cavity: Carve upper space for lamp shade
        up(base_height - 2 * lug_size - edge_gap)
            cyl(d=base_size - 2 * wall_thickness + 2 * tolerance,
                h=2 * lug_size + 2 * edge_gap, anchor=BOTTOM);

        // Lug slots
        lug_radius = base_size / 2 - 2 * lug_size - edge_gap;
        up(tolerance)
            all_lugs(lug_radius, arc_scale=2.5);
        down(tolerance)
            all_lugs(lug_radius, arc_scale=2.5);
        all_lugs(lug_radius, slot=true);
    }
}

right(.7 * base_size)
    led_holder();
left(.7 * base_size)
    lamp_base();
