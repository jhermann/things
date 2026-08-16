# Parametric AC Hose Adapter with Insect Grill

> Feed resulting SCAD into https://makerworld.com/en/makerlab/parametricModelMaker

Create an AC hose adapter as a OpenSCAD model, consisting of these parts:

- square base plate with rounded edges, chamfered on the bottom side on the edge of the rounded rectangle
- a hole in the middle
- a hollow cylinder sticking out of that hole on one side, with an outer diameter of the hose but tolerance subtracted; the bottom end sits flat with the plate bottom
- the rim of the cylinder away from the plate is rounded on its outside edge, by *adding* a quarter circle shaped rim on top (wall size radius)
- that added quarter circle sits on top of the hose connector cylinder wall (extending it), making fitting the hose easier; the 90° corner of that quarter circle sits on the upper inside edge of the hose tube wall (arc facing outside and upwards); the arc must be convex, not concave
- the hole is filled with a hex grid as an insect screen, with a given wall thickness and height
- make the grill very lean to minimize air flow friction, just consisting of thin walls, like a honey bee makes them, or a hex infill pattern
  (effectively making the walls 2 lines thick when hex tubes are placed adjacent to each other)
- add a groove for self-adhesive insulating foam tape, with the given width, and 90% of the tape thickness deep; keep a distance to the plate edge using the given chamfer size; the groove is four straight lines on the upper side of the base plate, so the tape can be easily applied
- stop the grooves early in the corners to not cut into them, but still meet on the inner side. For that, cut the corner radius plus the chamfer size from the groove length on both ends (so it is `plate size - 2*chamfer size - 2*corner radius` in total length).

Integrate this code for the hex grid:

```
// --- Customizable Parameters ---
grid_width = 100;       // Total width of the grid (X axis)
grid_length = 100;      // Total length of the grid (Y axis)
grid_height = 5;        // Thickness of the grid (Z axis)

cell_flat_to_flat = 8;  // Internal width of a single cell (diameter across flats)
wall_thickness = 1.2;   // Perfectly uniform thickness of every single wall

/* [Hidden] */
$fn = 6;                // Forces 6-sided cylinders (hexagons)
edge_pad = 1;           // Prevents mathematical artifacts during subtraction

// --- Mathematical Calculations for True Honeycomb Alignment ---
// Distance from center to flat edge
r_inner = cell_flat_to_flat / 2; 
// Distance from center to point (outer radius)
r_outer = r_inner / cos(30); 

// Exact spacing needed so parallel walls maintain uniform thickness
x_spacing = (r_inner * 2) + wall_thickness;
y_spacing = x_spacing * sin(60); // Exact height of the staggered row triangle

// --- Main Execution ---
difference() {
    // 1. Outer boundary block
    cube([grid_width, grid_length, grid_height]);
    
    // 2. Honeybee cell cutouts
    honeycomb_mask();
}

// --- Modules ---
module honeycomb_mask() {
    cols = ceil(grid_width / x_spacing) + 1;
    rows = ceil(grid_length / y_spacing) + 1;
    
    for (col = [-1 : cols]) {
        for (row = [-1 : rows]) {
            // Stagger alternating rows by half a column width
            x_offset = (row % 2 == 0) ? 0 : x_spacing / 2;
            
            x_pos = (col * x_spacing) + x_offset;
            y_pos = row * y_spacing;
            
            // Cut out the true hexagonal cell
            translate([x_pos, y_pos, -edge_pad])
                rotate([0, 0, 30]) // 30-deg rotation ensures flats face flats parallelly
                cylinder(r = r_outer, h = grid_height + (edge_pad * 2));
        }
    }
}
```

## OpenSCAD Model Parameters

Hose connector:

* **`hose_diameter`**: `150 mm`
*Nominal outer diameter of the hose.*
* **`hose_connector_height`**: `55 mm`
*Height of the straight cylindrical section.*
* **`wall_thickness`**: `2.5 mm`
*Wall thickness for the main hose connector cylinder and top rim radius.*
* **`tolerance_gap`**: `0.15 mm`
*Clearance subtracted from the outer radius for smooth fitting into the hose.*

Base plate:

* **`base_plate_rim`**: `15 mm`
*Extra margin width added around the cylinder to form the base plate.*
* **`base_plate_thickness`**: `4 mm`
*Height/thickness of the base plate (and total height of the embedded hex screen).*
* **`base_corner_radius`**: `10 mm`
*Corner fillet radius for rounding the square base plate.*
* **`base_bottom_chamfer`**: `1.5 mm`
*Chamfer distance along the bottom outer edge of the base plate (prevents elephant foot).*
* **`foam_tape_groove_width`**: `10 mm`
*Width of the recessed groove for self-adhesive insulating foam tape.*
* **`foam_tape_thickness`**: `1 mm`
*Thickness of the foam tape; the groove depth should be 90% of that.*

Insect screen:

* **`grid_hole_size`**: `2.1 mm`
*Inner flat-to-flat distance of each hexagonal opening in the insect screen.*
* **`grid_wall_thickness`**: `0.6 mm`
*Shared wall thickness between adjacent hex holes.*
* **`grid_height`**: `1.2 mm`
*Height of the hexagonal insect screen.*

Quality:

* **`$fn`**: `120`
*Circle resolution parameter for high-detail geometric rendering.*

## Guardrails / Checks

- the groove cannot be missing, cut it out of the plate
- the arc of the quarter circle cannot be concave, I want it convex
- the arc of the quarter circle must point upward and to the outside
- make the grooves long enough so they overlap a bit (chamfer size on both ends of each segment)
- the base plate chamfer is on the rounded rect, not the hose cylinder