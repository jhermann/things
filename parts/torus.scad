// Fast preview, smooth final curves
$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.1;

// rotational extrusion of an ellipsoid with its center at `radius`
module torus(radius, rx, ry, arc=360) {
    rotate_extrude(angle=arc, convexity=2)
        translate([radius, 0, 0])
            scale([rx, ry, 1])
                circle(r=1, $fn=$fn);
}

torus(30, 5, 10, 240);
