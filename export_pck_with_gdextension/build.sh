#!/bin/bash

# Build godot editor:
cd ../..

cd godot
scons platform=linuxbsd dev_build=yes
cd -

# Dump extension API
cd godot-cpp/gdextension/
../../godot/bin/godot.linuxbsd.editor.dev.x86_64 --headless --dump-extension-api --dump-gdextension-interface 
cd -

# Build godot-cpp
cd godot-cpp
scons platform=linux dev_build=yes 
cd -

# Build gdexample
cd godot-tests/export_pck_with_gdextension/
scons platform=linux dev_build=yes
cd -

# Build the game template
cd godot
scons platform=linuxbsd target=template_debug arch=x86_64 dev_build=yes optimize=none
cd -

# Export the game exe with main_project
godot/bin/godot.linuxbsd.editor.dev.x86_64 --headless --path godot-tests/export_pck_with_gdextension/main_project/ --export-debug "Dev"

# Export mod_project as pck
godot/bin/godot.linuxbsd.editor.dev.x86_64 --headless --path godot-tests/export_pck_with_gdextension/mod_project/ --export-pack "Dev" ../../../godot/bin/mod.pck

# Deploy
mkdir -p ~/".local/share/godot/app_userdata/Main Project/bin/"
cp godot-tests/export_pck_with_gdextension/mod_project/bin/*.so ~/".local/share/godot/app_userdata/Main Project/bin/"
cp godot/bin/mod.pck ~/".local/share/godot/app_userdata/Main Project/"