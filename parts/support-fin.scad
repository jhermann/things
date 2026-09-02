// A parametric triangular designed supports holding up objects printed on an edge or corner.
include <BOSL2/std.scad>

/* [Support fin] */
fin_size = 20;
fin_thickness = 1;
fin_gap = .75;
cuboid_size = 30;

/* [Hidden] */

$fa = $preview ? 8 : 1;
$fs = $preview ? 1 : 0.1;

// Creates a triangular gusset with its long edges on the X and Z axes.
module support_fin(size, thickness) {
    chamfer = thickness / 4;
    tine_width = .45;
    tine_heigth = .3;

    back(tine_width / 2)
    union() {
        right(size / 2 + fin_gap) up(size / 2) yrot(45) xrot(90) {
            // The tines that help the support fin connect to the object
            step = 4 * thickness;
            for (h = [0 : step : size * sqrt(2) - step]) {
                color("yellow")
                translate([-.25 * fin_gap * sqrt(2), h - size / sqrt(2) + thickness / 2, 0])
                    zrot(45)
                    cube([fin_gap * sqrt(2), tine_heigth, tine_width], center = true);
            }

            // The actual triangular gusset
            color("red")
            //back( / 2) zrot(45)
            linear_extrude(height = thickness, center = true)
                offset(r = thickness / 3) offset(delta = -thickness / 3)
                polygon(points = [
                    [0, -size / sqrt(2)],
                    [0, size / sqrt(2)],
                    [size / sqrt(2), 0]
                ]);
        }

        // Bed adhesion helper
        right(size + fin_gap + chamfer)
            color("blue")
            scale([0.5, 1, 1])
            cyl(r = .95 * size, h = thickness, anchor = BOTTOM, chamfer = chamfer);
    }
}


color("grey")
//move_to([0, 0, 0], anchor=BOT)
translate([0, cuboid_size / 2, (cuboid_size - fin_thickness) / sqrt(2)])
    //offset(r = fin_thickness) offset(delta = -fin_thickness)
    yrot(45)
        cuboid([cuboid_size, cuboid_size, cuboid_size], chamfer = fin_thickness);
back(fin_thickness / 2) right(fin_gap / 3)
    support_fin(fin_size, fin_thickness);
back(cuboid_size - fin_thickness / 2) left(fin_gap / 3)
    zrot(180)
    support_fin(fin_size, fin_thickness);
