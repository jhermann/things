// Define the dimensions of the object
corner_radius = 5;
chamfer_size = 1;

// Define the dimensions of the holes
hole_diameter = 27;
hole_height = 25;
height = hole_height + 4.3 + 2;

// Calculate the spacing between the holes
hole_spacing = 6;
depth = hole_diameter + hole_spacing/2;
width = 3*hole_diameter + 3*hole_spacing;

corner_hole_diameter = 6.2;
corner_hole_depth = 0.2;
corner_hole_offset = 5.5;

// Create the main object with rounded corners
module rounded_rectangle(width, depth, height, corner_radius) {
    hull() {
        translate([corner_radius, corner_radius, 0])
            cylinder(h = height, r = corner_radius);
        translate([width - corner_radius, corner_radius, 0])
            cylinder(h = height, r = corner_radius);
        translate([corner_radius, depth - corner_radius, 0])
            cylinder(h = height, r = corner_radius);
        translate([width - corner_radius, depth - corner_radius, 0])
            cylinder(h = height, r = corner_radius);
    }
}

// Create the main object with chamfers
module chamfered_rectangle(width, depth, height, corner_radius, chamfer_size) {
    minkowski() {
        rounded_rectangle(width - 2 * chamfer_size, depth - 0 * chamfer_size, height - 2 * chamfer_size, corner_radius - chamfer_size);
        cylinder(h = chamfer_size, r1 = chamfer_size, r2 = 0);
    }
}

// Create the holes
module holes() {
    for (i = [0 : 2]) {
        translate([(width - 3 * hole_diameter - 1 * hole_spacing) / 2 + i * (hole_diameter + hole_spacing*.75)+1.75*hole_spacing, depth / 2, height - hole_height])
            cylinder(h = hole_height, d = hole_diameter - 3*(i%2));
    }
}

// Create the corner holes
module corner_holes() {
    translate([chamfer_size + corner_hole_offset, corner_hole_offset, 0])
        cylinder(h = corner_hole_depth, d = corner_hole_diameter);
    translate([width - 2*chamfer_size - corner_hole_offset, corner_hole_offset, 0])
        cylinder(h = corner_hole_depth, d = corner_hole_diameter);
    translate([chamfer_size + corner_hole_offset, depth - corner_hole_offset, 0])
        cylinder(h = corner_hole_depth, d = corner_hole_diameter);
    translate([width - 2*chamfer_size - corner_hole_offset, depth - corner_hole_offset, 0])
        cylinder(h = corner_hole_depth, d = corner_hole_diameter);
}

// Create the final object
difference() {
    chamfered_rectangle(width, depth, height, corner_radius, chamfer_size);
    holes();
    corner_holes();
}