# Parametric AC Exhaust Vent Cover

Create an OpenSCAD model of a cover for an AC hose exchaust, with integrated grill that deflects the air at a given angle.

- a hollow cylinder (tube) is the main body, with an outer diameter of the hose but tolerance subtracted.
- the outside end of the vent has a rim around its edge, sitting on the print plate.
- within the vent cover tube there are grill fins with a given spacing, angle, and height.
- perpendicular to the fins there is a vertical stabilizer rectangle (not angled) conencting them in the middle.
- the with of the angled fins is calculated so that they go up to the given grill height.
- at the inner end of the tube, there are four spring tongues excerting pressure for a better fit.
- they have a given depth which is also their width, and they are made by cutting two vertical slits into the hose wall, a wall thickness wide and the tongue size high.
- on the outside of those tongues there are segments cut from an ellipsoid, with the diameter of the segment equal to the tongue size minus a wall thickness.
- the ellipsoid segment is centered on the tongue, and extends `2*tolerance_gap` outwards beyond the tube perimeter. It does however not extend into the slits and is clipped there.
- the ellipsoid segments vertical center plane is positioned flush with the outer tube wall.
- to fully connect segment and tongue, the segment overlaps into the tongue with half a wall thickness.
- the tongue thickness is reduced to 1mm to be flexible enough (thinner than the wall), and placed on the outer edge of the tube.
- make sure there are no remnants of the inner tube wall when slimming the tongues, by extending negative parts a bit into the empty tube space.

## OpenSCAD Model Parameters

Vent cover:

* **`vent_diameter`**: `144.65 mm`
*Nominal outer diameter of the vent.*
* **`vent_tube_depth`**: `35 mm`
*Height of the straight cylindrical section.*
* **`wall_thickness`**: `1.5 mm`
*Wall thickness for the main hose connector cylinder.*
* **`tolerance_gap`**: `0.15 mm`
*Clearance subtracted from the outer radius for smooth fitting into the hose.*

Vent rim:

* **`rim_size`**: `10 mm`
*Extra margin width added around the cylinder to form the rim.*
* **`rim_thickness`**: `3 mm`
*Height/thickness of the rim.*
* **`rim_bottom_chamfer`**: `1 mm`
*Chamfer distance along the bottom outer edge of the rim (prevents elephant foot).*

Grill fins:

* **`grill_distance`**: `12 mm`
*Spacing of the grill fins.*
* **`grill_angle`**: `45 deg`
*Angle of the grill fins.*
* **`grill_height`**: `15 mm`
*Height of the angled grill fins and the stabilizer.*
* **`grill_thickness`**: `1 mm`
*Wall thickness of the grill fins.*

Spring tongues:
* **`tongue_size`**: `10 mm`
*Height and width of the springs.*

Quality:

* **`$fn`**: `120`
*Circle resolution parameter for high-detail geometric rendering.*
