// https://www.thingiverse.com/thing:7021925
// by [divbyzero](https://www.thingiverse.com/divbyzero/designs)
// licensed under CC-BY-SA 4.0 https://creativecommons.org/licenses/by-sa/4.0/

// -------------------------
// Parameters
// -------------------------

n = 10;             // Number of subintervals
a = 1;              // Starting x-coordinate
b = 3;              // Ending x-coordinate
sample_type = "mid"; // Sampling method: "left", "mid", or "right"
show_solid = !$preview; // true = render full solid surface; false = stacked disks/washers
printedwidth = 90;    // Desired printed width in millimeters

// Scaling factor to match printed width
scalefactor = printedwidth / (2 * b);

// -------------------------
// Functions defining the solid
// -------------------------

// In this model, we a region in the xy-planed defined by a top function y = f(x), a bottom function y = g(x), and lines x = a ≥ 0 and x = b > a. The region is revolved around the y-axis to produce a solid.
// The shell model devides the interval [a,b] into n equal subintervals. The chosen sample point determines the top and bottom of the rectangle above a subinterval. The rectangle is revolved about the y-axis to obtain a shell. All the shells together give an approximate volume.

// Top function: defines top surface y = f(x)
function f(x) = 3 - 3 * (x - 2) * (x - 2);

// Bottom function: defines bottom surface y = g(x)
function g(x) = 0;

// -------------------------
// Model resolution
// -------------------------

$fn = 200; // Number of facets for circle smoothness

// -------------------------
// Modules
// -------------------------

// Shell Module: creates a thin hollow cylindrical shell
module shell(r_mid, z_bottom, height, thickness) {
    translate([0, 0, z_bottom * scalefactor])
        difference() {
            // Outer cylinder: correct height and radius
            cylinder(h = height * scalefactor, r = (r_mid + thickness/2) * scalefactor, center = false);
            // Inner cylinder: slightly taller and offset to avoid coplanar faces
            translate([0, 0, -0.1 * scalefactor])
                cylinder(h = (height + 0.2) * scalefactor, r = (r_mid - thickness/2) * scalefactor, center = false);
        }
}

// Solid Surface Module: generates full continuous solid by revolving region
module solid_surface() {
    rotate_extrude() {
        polygon(points = [
            for (x = [a : (b - a) / 100 : b])
                [x * scalefactor, f(x) * scalefactor],
            for (x = [b : -(b - a) / 100 : a])
                [x * scalefactor, g(x) * scalefactor]
        ]);
    }
}

// -------------------------
// Sample point selection
// -------------------------

// Selects sample point for a subinterval based on sampling method
function sample_x(i, interval, a) =
    (sample_type == "left") ? (a + i * interval) :
    (sample_type == "right") ? (a + (i + 1) * interval) :
    (a + (i + 0.5) * interval); // Default: midpoint sampling

// -------------------------
// Main Logic
// -------------------------

interval = (b - a) / n;

if (show_solid) {
    solid_surface();
} else {
    for (i = [0 : n-1]) {
        x_sample = sample_x(i, interval, a);
        r_mid = x_sample;
        height = f(x_sample) - g(x_sample);
        z_bottom = g(x_sample);
        thickness = interval;

        if (height > 0) {
            shell(r_mid = r_mid, z_bottom = z_bottom, height = height, thickness = thickness);
        }
    }
}
