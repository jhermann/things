// --- 1. PARAMETERS (Shows up in the MakerWorld Customizer UI) ---
/* [Box Settings] */
box_width = 60;
box_length = 60;
box_height = 40;

/* [Lid Settings] */
lid_thickness = 3;

// --- 2. MAIN ASSEMBLY MODULE (Default View) ---
// MakerWorld uses the root assembly view to generate the 3D preview.
main_assembly();

module main_assembly() {
    // View both parts assembled together
    box_body();
    translate([0, 0, box_height]) lid();
}

// --- 3. MAKERWORLD MULTI-PLATE MODULES ---
// PMM automatically maps these exact module names to separate plates in the 3MF export.

module mw_plate_1() {
    // CRITICAL: Plate 1 cannot be empty, or validation will fail.
    // Orient the part flat on the print bed.
    box_body();
}

module mw_plate_2() {
    // The second plate contains the second part oriented for printing.
    lid();
}


// --- 4. INDIVIDUAL GEOMETRY MODULES ---
module box_body() {
    difference() {
        cube([box_width, box_length, box_height], center = true);
        translate([0, 0, 2])
            cube([box_width - 4, box_length - 4, box_height], center = true);
    }
}

module lid() {
    cube([box_width, box_length, lid_thickness], center = true);
}
