#!/usr/bin/env bash
#
# Render each OpenSCAD texture to a PNG and combine the results into a tiled
# preview image.
#
# Requires OpenSCAD Nightly at the configured Windows path, wslpath, and
# ImageMagick's montage command. Run from WSL with: ./preview.sh

# Configuration
openscad_windows_path='c:\Program Files\OpenSCAD (Nightly)\openscad.exe'
image_width=320
image_height=$image_width
tile_columns=3
colorscheme='Nocturnal Gem'
background_color='black'
text_color='white'
preview_filename='preview.png'

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
binary=$(wslpath -u "$openscad_windows_path")
output_dir=$(mktemp -d)
trap 'rm -rf "$output_dir"' EXIT
montage_args=()

for scad_file in "$script_dir"/*.scad; do
	filename=$(basename "$scad_file" .scad)
	IFS='-' read -ra label_parts <<< "$filename"
	label=''
	for label_part in "${label_parts[@]}"; do
		label+=" ${label_part^}"
	done
	label=${label# }
    echo "Rendering $filename..."
	"$binary" --colorscheme "$colorscheme" --viewall \
        --imgsize="$image_width,$image_height" -o "$output_dir/$filename.png" "$scad_file"
	montage_args+=(-label "$label" "$output_dir/$filename.png")
done

montage "${montage_args[@]}" \
	-tile "${tile_columns}x" \
	-geometry "${image_width}x${image_height}" \
	-background "$background_color" \
	-fill "$text_color" \
	"$script_dir/$preview_filename"
