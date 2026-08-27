// Edge length of the cube.
edge_size = 20;
hole_size = edge_size / 2;

// Cut a centered square hole vertically through the cube.
difference() {
    cube([edge_size, edge_size, edge_size]);

    translate([
        (edge_size - hole_size) / 2,
        (edge_size - hole_size) / 2,
        -1
    ])
        cube([hole_size, hole_size, edge_size + 2]);
}
