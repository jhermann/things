#!/usr/bin/env bash
#
# Render OpenSCAD files to PNGs and combine files from each directory into a
# tiled preview image in that directory.
#
# Requires OpenSCAD Nightly at the configured Windows path, wslpath, and
# ImageMagick's montage command. Run from WSL with: ./scripts/preview.sh
#
# To get a list of fonts:
#   convert -list font | grep -i font: | cut -f2- -d:

# Configuration
openscad_windows_path='c:\Program Files\OpenSCAD (Nightly)\openscad.exe'
image_width=320
image_height=$image_width
tile_columns=3
colorscheme='Nocturnal Gem'
background_color='black'
text_color='white'
text_font='Noto-Sans-Mono-Bold'
preview_filename='preview.png'

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
search_dir="$(cd "$script_dir/.." && pwd)"
binary=$(wslpath -u "$openscad_windows_path")
output_dir=$(mktemp -d)
trap 'rm -rf "$output_dir"' EXIT
scad_dir_count=0

for scad_dir in parts parts/textures examples; do
    scad_dir="$search_dir/$scad_dir"
    [ -d "$scad_dir" ] || continue

	montage_args=()
	scad_count=0
    echo "Processing directory: $scad_dir..."

	for scad_file in "$scad_dir"/*.scad; do
        [ -e "$scad_file" ] || continue
		filename=$(basename "$scad_file" .scad)
		label=$(printf '%s' "$filename" | sed -E 's/([a-z])([A-Z])/\1 \2/g; s/-/ /g; s/(^| )([^ ])([a-z]*)/\1\U\2\L\3/g')
		((scad_count += 1))
		output_file="$output_dir/$scad_dir_count-$scad_count.png"
		relative_file=${scad_file#"$search_dir/"}
		echo "Rendering $relative_file..."
		"$binary" --colorscheme "$colorscheme" --viewall \
			--imgsize="$image_width,$image_height" -o "$output_file" "$scad_file"
		montage_args+=(-label "$label" "$output_file")
	done < <(find "$scad_dir" -maxdepth 1 -type f -name '*.scad' -print0 | sort -z)

	((scad_dir_count += 1))
	montage "${montage_args[@]}" \
		-tile "${tile_columns}x" \
		-geometry "${image_width}x${image_height}" \
		-background "$background_color" \
		-fill "$text_color" \
		-font "$text_font" \
		"$scad_dir/$preview_filename"
done

if ((scad_dir_count == 0)); then
	echo "No SCAD files found under $search_dir" >&2
	exit 1
fi
