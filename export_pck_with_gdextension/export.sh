#!/bin/bash

# Build godot editor:
cd ../..

# Export the game exe with main_project
godot/bin/godot.linuxbsd.editor.dev.x86_64 --headless --path godot-tests/export_pck_with_gdextension/main_project/ --export-debug "Dev"

# Export mod_project as pck
godot/bin/godot.linuxbsd.editor.dev.x86_64 --headless --path godot-tests/export_pck_with_gdextension/mod_project/ --export-pack "Dev" ../../../godot/bin/mod.pck

# Deploy
mkdir -p ~/".local/share/godot/app_userdata/Main Project/bin/"
cp godot-tests/export_pck_with_gdextension/mod_project/bin/*.so ~/".local/share/godot/app_userdata/Main Project/bin/"
cp godot/bin/mod.pck ~/".local/share/godot/app_userdata/Main Project/"