# OpenSCAD Model With Animation Video and *MakerWorld* Multi-Plate Support <!-- omit from toc -->

*Contents*

- [Motivation and Purpose](#motivation-and-purpose)
- [Using an Animation to Visualize Key Concepts](#using-an-animation-to-visualize-key-concepts)
- [Working With the Model](#working-with-the-model)
  - [1. Get the Files](#1-get-the-files)
  - [2. Choose the Dimensions](#2-choose-the-dimensions)
  - [3. Inspect the Assembly](#3-inspect-the-assembly)
  - [4. Export the *MakerWorld* Plates](#4-export-the-makerworld-plates)
  - [5. Attach the Hoses](#5-attach-the-hoses)
- [Create the Model Animation](#create-the-model-animation)
- [Reference Links](#reference-links)

## Motivation and Purpose

I made a [parametric bayonet connector for AC hoses](https://makerworld.com/en/models/3220030-ac-hose-bayonet-quick-connectors), to attach such hoses to a mobile AC unit and a typical window kit taking the hot air outside. It is part of my [Air Conditioning Collection](https://makerworld.com/en/collections/33754690-air-conditioning) on *MakerWorld*.

And of course, I prefer code over using some GUI CAD application, leading straight to *OpenSCAD* as the established standard for 3D-models-as-code. It is also one of the few ways *MakerWorld* models can be made customizable by the end user.

The connector allows attaching a hose with a simple push and a short twist, instead of needing a threaded joint or tools every time the hose is removed.

The design has three printable parts:

- A female connector with bayonet slots on the inside.
- A male connector with matching lugs.
- A female adapter with a wider fitting section for joining to an existing tube, like the one on an air intake cover.

> ![Model Parts](https://raw.githubusercontent.com/jhermann/things/refs/heads/main/models/ac-bayonet-connectors/assets/model-parts.jpg)

The male lugs fit into the slots in the female connector. Push the parts together, twist them, and the lugs travel along the horizontal parts of the L-shaped slots. This is the same basic idea used by bayonet light fittings, camera mounts, and other quick-release connectors. See the [Bayonet mount overview][bayonet-mount] for useful background.

The hose itself is held on the printed connector with a worm-drive hose clamp. A screw on the clamp pulls the perforated band tight around the hose. See the [Hose clamp reference][hose-clamp] for an explanation of that mechanism.

## Using an Animation to Visualize Key Concepts

The OpenSCAD file contains code that creates a 10-scene animation. It shows the female connector turning to expose the slots, the hose and male connector moving into position, the male part twisting to lock, and the parts separating again. It also emphasises the parametric nature of the model by showing a change of the two main parameters, hose diameter and fitting height.

The animation is not just decoration — it makes the hidden bayonet slots easier to understand before printing the parts.

## Working With the Model

### 1. Get the Files

Clone the [things][things-repo] repo to get all required model files.

Install the [OpenSCAD Nightly Build][openscad-downloads] to view SCAD files, or alternatively add a SCAD live preview extension like [Carve](https://marketplace.visualstudio.com/items?itemName=Carve3D.carve) to *VS Code*.

The [hose-connector-multi-plate.scad][multi-plate-source] script targets some special features offered by *MakerWorld*, using the bespoke `mw_plate_N()` module names. To see this, open the [*MakerWorld* Parametric Model Maker][makerworld-model-maker], where you can also download a 3MF file for your slicer.

For creating the animation video, the project also includes a subtitle file named [subtitles.srt][subtitles].

### 2. Choose the Dimensions

Open the [*MakerWorld* Parametric Model Maker][makerworld-model-maker] link. Wait for the model to load, then use the parameter controls to enter your measurements in millimetres:

- Set `hose_diameter` to the inside diameter of your hose.
- Set `hose_connector_height` to the length of the straight fitting section.
- Adjust `wall_thickness` if you prefer a different wall size.
- Adjust `tolerance_gap` if your printer consistently makes holes too tight or too loose.

The default values are a 150 mm hose diameter, a 45 mm fitting height, a 2.5 mm wall thickness, and a 0.15 mm tolerance gap. The diameter and length are limited by what fits into your printer's build volume.

> ![Model Parameter](https://raw.githubusercontent.com/jhermann/things/refs/heads/main/models/ac-bayonet-connectors/assets/hose-connector-female-params.png)

Measure your real hose before entering the diameter value; nominal hose sizes are not always the same as their measured inside diameter. Check the preview after changing the parameters and make sure the hose can slide over the fitting by using the measuring tool in your slicer. Section 4 explains how to download the customized 3MF with all three plates.

### 3. Inspect the Assembly

Open `hose-connector-multi-plate.scad` in OpenSCAD and press Preview (F5) or Render (F6). The script starts with the parts arranged as an assembly. The file uses lower detail for previews and finer curves for final output, so the preview should be faster than a final render.

The variables `animate = 0` and `local = 0`, set at the top of the script, fit the model maker case. Comment the line with those settings and uncomment the line below it for local use and watching the animation within OpenSCAD

The *MakerWorld* model creator looks out for the three modules `mw_plate_1()`, `mw_plate_2()`, and `mw_plate_3()`, placing each printable part on its own plate.

### 4. Export the *MakerWorld* Plates

Upload the SCAD file through the *MakerWorld* Parametric Model Maker link above and set your dimensions in the customizer. The generated download is a 3MF containing three plates:

1. Plate 1: the female hose connector.
2. Plate 2: the male hose connector.
3. Plate 3: the female adapter with the tube extension.

Open the 3MF in your slicer, check the fit and orientation, and slice the parts. The models are intended to print without supports on a printer that can handle 45° overhangs.

Do not use PLA for these parts. Use a material with better heat and UV resistance instead, such as PETG or PCTG, and choose a material and print settings suitable for the temperatures and environment around your AC equipment.

### 5. Attach the Hoses

Push each hose over its connector. Do not forget to fit a worm-drive hose clamp over the hose end before that, and tighten it carefully. The clamp is not included in the animation, but it is needed to secure the hose to the printed connector.

To connect the printed parts, line up the male lugs with the female slot openings, push the male connector fully home, and twist in the direction marked on the outside of the female connector housing. To remove it, twist in the opposite direction.

## Create the Model Animation

The SCAD file divides the animation video into 10 scenes and uses OpenSCAD's `$t` animation value to progress through them, going from 0.0 to 1.0 in steps depending on the amount of requested frames. OpenSCAD documents `$t`, animation steps, and camera variables in its [animation documentation][animation-docs]. The [OpenSCAD documentation page][openscad-docs] also links to the language reference and command-line manual.

From a terminal in the model folder, run the commands from the README. On Windows, OpenSCAD is likely not on your `PATH` and a working command may look like this:

```text
"C:\Program Files\OpenSCAD (Nightly)\openscad.exe" -o frame.png --colorscheme "Nocturnal Gem" --animate 180 --camera=400,400,-300,0,0,50 hose-connector-multi-plate.scad

convert -delay 7 -loop 0 frame*.png hose-connector-animation.gif

ffmpeg -y -framerate 6 -i frame%05d.png -vf "subtitles=subtitles.srt" -c:v libx264 -pix_fmt yuv420p hose-connector-animation.mp4
```

The first command asks OpenSCAD for 180 animation frames and defines the camera position by specifying an eye line. The second combines the generated frames into a looping GIF using [ImageMagick][imagemagick]. The last command creates a MP4 video at six frames per second and burns in the captions using [FFmpeg][ffmpeg]. On Windows, these last two commands are probably better executed in a WSL virtual machine.

On Linux or macOS, replace the Windows executable path with `openscad` if it is on your `PATH`. Recent ImageMagick installations may use `magick` instead of `convert`, so the second command may be:

```text
magick -delay 7 -loop 0 frame*.png hose-connector-animation.gif
```

The frame files are temporary render output. Keep the GIF or MP4 and remove the individual PNG files when you are finished and do not need them anymore.

## Reference Links

- [Project README and print notes][project-readme]
- [Multi-plate OpenSCAD source][multi-plate-source]
- [*MakerWorld* Air Conditioning collection][makerworld-collection]
- [OpenSCAD downloads][openscad-downloads]
- [OpenSCAD documentation][openscad-docs]
- [OpenSCAD animation reference][animation-docs]
- [Bayonet mount background][bayonet-mount]
- [Worm-drive hose clamp background][hose-clamp]

[things-repo]: https://github.com/jhermann/things
[project-readme]: https://github.com/jhermann/things/blob/main/models/ac-bayonet-connectors/README.md
[multi-plate-source]: https://github.com/jhermann/things/blob/main/models/ac-bayonet-connectors/hose-connector-multi-plate.scad
[subtitles]: https://github.com/jhermann/things/blob/main/models/ac-bayonet-connectors/subtitles.srt
[makerworld-model-maker]: https://makerworld.com/en/makerlab/parametricModelMaker?designId=3220030&from=model_page&modelName=hose-connector-female.scad&scadUrl=https%3A%2F%2Fraw.githubusercontent.com%2Fjhermann%2Fthings%2Frefs%2Fheads%2Fmain%2Fmodels%2Fac-bayonet-connectors%2Fhose-connector-multi-plate.scad&unikey=f5a0b360-ef3e-4e34-942e-b1f3741da9e8
[makerworld-collection]: https://makerworld.com/en/collections/33754690-air-conditioning
[openscad-downloads]: https://openscad.org/downloads.html
[openscad-docs]: https://openscad.org/documentation.html
[animation-docs]: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Other_Language_Features#Animation
[imagemagick]: https://imagemagick.org/
[ffmpeg]: https://ffmpeg.org/
[bayonet-mount]: https://en.wikipedia.org/wiki/Bayonet_mount
[hose-clamp]: https://en.wikipedia.org/wiki/Hose_clamp
