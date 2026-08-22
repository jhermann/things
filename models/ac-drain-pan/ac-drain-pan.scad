// AC condensate drain pan. Dimensions are millimetres.

/* [Basic Settings] */
wall_thickness = 2.5; // [1.0:0.1:5.0]
chamfer_size = 1.5; // [0.0:0.1:5.0]
box_height = 19; // [10:1:100]
box_width = 240; // [50:1:300]
box_depth = 200; // [50:1:300]
box_wall_angle = 82; // [45:1:89]

/* [Spout Settings] */
spout_width = 30; // [10:1:100]
spout_length = 25; // [10:1:100]

/* [Handle Settings] */
handle_length = 120; // [20:1:200]
handle_width = 5; // [1:0.5:20]
handle_height = 25; // [10:1:100]
handle_radius = 10; // [1:1:20]

/* [Hidden] */
$fn = 64; // [16, 32, 64, 128]

bottom_width = box_width - 2 * box_height / tan(box_wall_angle);
bottom_depth = box_depth - 2 * box_height / tan(box_wall_angle);
inner_top_width = box_width - 2 * wall_thickness;
inner_top_depth = box_depth - 2 * wall_thickness;
inner_bottom_width = inner_top_width -
	2 * (box_height - wall_thickness) / tan(box_wall_angle);
inner_bottom_depth = inner_top_depth -
	2 * (box_height - wall_thickness) / tan(box_wall_angle);

assert(bottom_width > 2 * wall_thickness);
assert(bottom_depth > 2 * wall_thickness);

module chamfered_rect(width, depth, chamfer) {
	polygon([
		[-width/2 + chamfer, -depth/2], [width/2 - chamfer, -depth/2],
		[width/2, -depth/2 + chamfer], [width/2, depth/2 - chamfer],
		[width/2 - chamfer, depth/2], [-width/2 + chamfer, depth/2],
		[-width/2, depth/2 - chamfer], [-width/2, -depth/2 + chamfer]
	]);
}

module tapered_prism(bottom_w, bottom_d, top_w, top_d, height, chamfer=0) {
	hull() {
		linear_extrude(height=0.01)
			chamfered_rect(bottom_w, bottom_d, chamfer);
		translate([0, 0, height])
			linear_extrude(height=0.01)
				chamfered_rect(top_w, top_d, chamfer);
	}
}

module pan_outer() {
	tapered_prism(bottom_width, bottom_depth, box_width, box_depth,
				  box_height, chamfer_size);
}

module pan_cavity() {
	translate([0, 0, wall_thickness])
		tapered_prism(inner_bottom_width, inner_bottom_depth,
					  inner_top_width, inner_top_depth, box_height + 1,
					  max(0.2, chamfer_size - 0.2));
}

module rounded_rect(width, height, radius) {
	radius = min(radius, min(width, height) / 2);
	hull() {
		for (y = [-width/2 + radius, width/2 - radius])
			for (z = [-height/2 + radius, height/2 - radius])
				translate([y, z]) circle(r=radius);
	}
}

// A U profile made by extruding the upper half of a rounded-rectangle ring.
module handle(side) {
	// The outside face is flush with the wall; the handle extends inward.
	x = side * (box_width / 2 - handle_width / 2);
	translate([x, 0, box_height])
		rotate([0, 90, 0])
			linear_extrude(height=handle_width, center=true)
				difference() {
					intersection() {
						difference() {
							rounded_rect(2 * handle_height, handle_length,
										 handle_radius);
							rounded_rect(2 * handle_height - 2 * handle_width,
										 handle_length - 2 * handle_width,
										 max(0.5, handle_radius - handle_width));
						}
						// Keep profile x <= 0. Rotation maps this to the
						// portion above the box rim.
						translate([-handle_height / 2, 0, 0])
							square([handle_height, handle_length + 2], center=true);
					}
				}
}

// Square end pillars extend each handle leg to the bottom and follow the
// tapered outer wall instead of using separate wedges.
module handle_pillars(side) {
	x = side * (box_width / 2 - handle_width / 2);
	for (y = [-1, 1] * (handle_length / 2 - handle_width / 2))
		intersection() {
			translate([x, y, box_height / 2])
				cube([handle_width, handle_width, box_height], center=true);
			pan_outer();
		}
}

// Rectangular U-channel on the back (+Y) wall, open upward and inward.
module spout_channel() {
	wall_penetration = box_height / tan(box_wall_angle) + wall_thickness;
	channel_length = spout_length + wall_penetration;
	// Keep the outlet end fixed while extending the channel inward through
	// the entire sloped back wall.
	y = box_depth / 2 + spout_length - wall_thickness - channel_length / 2;
	difference() {
		union() {
			translate([0, y, wall_thickness/2])
				cube([spout_width, channel_length, wall_thickness], center=true);
			for (x = [-spout_width/2 + wall_thickness/2,
					   spout_width/2 - wall_thickness/2])
				translate([x, y, box_height/2])
					cube([wall_thickness, channel_length, box_height], center=true);
		}
		// The channel may overlap the angled wall, but cannot enter the
		// pan's empty space.
		pan_cavity();
	}
}

// Vertical hollow half-cylinder, with its opening facing into the pan.
module spout_half_cylinder() {
	center_y = box_depth / 2 + spout_length - wall_thickness;
	translate([0, center_y, box_height / 2])
		difference() {
			intersection() {
				cylinder(h=box_height, r=spout_width / 2, center=true);
				translate([0, spout_width / 4, 0])
					cube([spout_width + 2, spout_width / 2,
						  box_height + 2], center=true);
			}
			intersection() {
				translate([0, 0, wall_thickness / 2])
					cylinder(h=box_height - wall_thickness + 1,
							 r=spout_width / 2 - wall_thickness, center=true);
				translate([0, spout_width / 4, 0])
					cube([spout_width + 4, spout_width / 2,
						  box_height + 3], center=true);
			}
		}
}

// Cut the back wall away so the rectangular channel opens into the cavity.
module spout_opening() {
	wall_penetration = box_height / tan(box_wall_angle) + wall_thickness;
	translate([0,
			   box_depth / 2 - wall_penetration / 2,
			   box_height / 2])
		cube([spout_width, wall_penetration + 2, box_height + 1],
			 center=true);
}

// The cavity and spout opening are cut first; the channel is then added back.
difference() {
	pan_outer();
	union() {
		pan_cavity();
		spout_opening();
	}
}

handle(-1);
handle(1);
handle_pillars(-1);
handle_pillars(1);
spout_channel();
spout_half_cylinder();
