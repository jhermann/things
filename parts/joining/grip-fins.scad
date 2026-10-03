// A hole with grip fins

include <BOSL2/std.scad>

/* [Grip fins] */
cube_size = 10; // [1:1:20]
hole_size = 4; // [1:0.5:10]
fin_size = 1; // [0.4:0.1:3]


/* [Hidden] */
//$preview = true;
local = 0;
$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.1;

wall_thickness = 1.5; // [0.4:0.1:5]
layer_height = 0.2;
tolerance = 0.25;
epsilon = 0.05;
chamfer = 0.3;

function eps(dim) = (dim + epsilon) / dim;

module gripping_hole(depth, radius, fin_size, angle=75) {
    fin_thickness = 1.5  * layer_height;
    fins = floor((2 * PI * radius) / (2.5 * fin_thickness));
    fin_extend = fin_size * (1 - cos(angle));

    // The hole itself
    offset_sweep(
        circle(radius),
        height = depth,
        top = os_chamfer(width=-chamfer),
        bottom = os_chamfer(width=-fin_extend),
        anchor=TOP,
    );

    // The fins
    down(depth / 2)
    zrot_copies(n=fins, r=radius - tolerance)
        zrot(angle)
        cuboid([fin_size + tolerance, fin_thickness, depth], anchor=LEFT, rounding=layer_height / 2);
}

if (0) color("red")
up(.5 * cube_size + epsilon)
gripping_hole(.75 * cube_size, hole_size / 2, fin_size);
if (1) difference() {
   //color("lime", alpha=.4)
    cuboid([cube_size, cube_size, cube_size], rounding=chamfer);
    up(.5 * cube_size + epsilon)
    gripping_hole(.75 * cube_size, hole_size / 2, fin_size);
}

fwd(cube_size)
cyl(r=hole_size / 2, height=cube_size, chamfer=chamfer);