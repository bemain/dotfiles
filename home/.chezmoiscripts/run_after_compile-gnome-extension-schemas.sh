#!/bin/bash
# Compiles gschemas for GNOME Shell extensions installed as externals.
# extensions.gnome.org zips ship raw .gschema.xml files; `gnome-extensions
# install` would normally compile them, but chezmoi just extracts the archive.

for schemas_dir in "$HOME"/.local/share/gnome-shell/extensions/*/schemas; do
	[ -d "$schemas_dir" ] || continue
	glib-compile-schemas "$schemas_dir"
done
