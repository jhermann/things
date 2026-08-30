// https://www.thingiverse.com/thing:7021924
// by [divbyzero](https://www.thingiverse.com/divbyzero/designs)
// licensed under CC-BY-SA 4.0 https://creativecommons.org/licenses/by-sa/4.0/

// -------------------------
// Details
// -------------------------

// In this model, we have a region in the xy-planed defined by an outer function x = f(y), an inner function x = g(y), and lines y = a ≥ 0 and y = b > a. The region is revolved around the y-axis to produce a solid.
// The disk/washer model devides the interval [a,b] into n equal subintervals. The chosen sample point determines the outer and inner extents of the rectangle for the subinterval. The rectangle is revolved about the y-axis to obtain a disk or washer. All the disks/washers together give an approximate volume.

// -------------------------
// Parameters
// -------------------------

n = 10;            // Number of subintervals
a = 0;             // Bottom y-coordinate
b = 0.75;          // Top y-coordinate
sample_type = "mid"; // Sampling method: "bottom", "mid", or "top"
show_solid = !$preview; // true = render full solid surface; false = stacked disks/washers
printedheight = 30;  // Desired printed height in millimeters

// Scaling factor to match printed height
scalefactor = printedheight / (b - a);

// -------------------------
// Functions defining the solid
// -------------------------

// Outer function: defines the outer curve in the region as a function of y
function f(y) = sqrt(3/4-y) + 1;

// Inner function: defines the inner curve in the region as a function of y
// Set g(y) = 0 to automatically switch to disk method (no hole)
function g(y) = 1/4 + y;

// -------------------------
// Model resolution
// -------------------------

$fn = 200; // Number of facets to approximate circles

// -------------------------
// Modules
// -------------------------

// Washer Module: creates a washer at a given z position
module washer(z_bottom, r_outer, r_inner, thickness) {
    translate([0, 0, z_bottom * scalefactor])
        difference() {
            cylinder(h = thickness * scalefactor, r = r_outer * scalefactor, center = false);
            translate([0, 0, -0.1 * scalefactor])
                cylinder(h = (thickness + 0.2) * scalefactor, r = r_inner * scalefactor, center = false);
        }
}

// Solid Surface Module: creates a full continuous solid of revolution
module solid_surface() {
    rotate_extrude() {
        polygon(points = [
            for (z = [a : (b - a) / 100 : b])
                [f(z) * scalefactor, z * scalefactor],
            for (z = [b : -(b - a) / 100 : a])
                [g(z) * scalefactor, z * scalefactor]
        ]);
    }
}

// Sample point selection based on sampling method
function sample_z(i, interval, a) =
    (sample_type == "bottom") ? (a + i * interval) :
    (sample_type == "top") ? (a + (i + 1) * interval) :
    (a + (i + 0.5) * interval); // Default to midpoint

// -------------------------
// Main Logic
// -------------------------

interval = (b - a) / n;

if (show_solid) {
    solid_surface();
} else {
    for (i = [0 : n-1]) {
        z_start = a + i * interval;
        z_sample = sample_z(i, interval, a);
        r_outer = f(z_sample);
        r_inner = g(z_sample);

        // If g(z) = 0, use a solid disk
        if (r_inner == 0) {
            washer(z_bottom = z_start, r_outer = r_outer, r_inner = 0, thickness = interval);
        }
        // Otherwise, create a washer
        else if (r_outer > r_inner) {
            washer(z_bottom = z_start, r_outer = r_outer, r_inner = r_inner, thickness = interval);
        }
    }
}
