extends Node


func _ready() -> void:
	print("[Main] Loading mod")

	var mod_folder_absolute := "user://"
	print("[Main] Searching for *.pck in %s" % mod_folder_absolute)

	var pck_files: Array[String] = find_files_with_extension(mod_folder_absolute, ".pck")
	if pck_files.is_empty():
		push_error("[Main] no pck found")
		return

	for pck_file_absolute: String in pck_files:
		print("[Main] Loading %s" % pck_file_absolute)

		# Loads the contents of the .pck file into the resource filesystem (res://)
		if not ProjectSettings.load_resource_pack(pck_file_absolute):
			push_error("[Main] load_resource_pack failed")
			return

	var bin_folder_absolute := "res://bin"
	print("[Main] Searching for *.gdextension in %s" % bin_folder_absolute)

	var gdextension_files: Array[String] = find_files_with_extension(bin_folder_absolute, ".gdextension")
	if gdextension_files.is_empty():
		push_error("[Main] no gdextension found")
		return

	for gdextension_file_absolute: String in gdextension_files:
		print("[Main] Loading %s" % gdextension_file_absolute)

		# Load the .gdextension resource
		var res = ResourceLoader.load(gdextension_file_absolute)
		if res == null:
			push_error("[Main] Failed to load GDExtension at: " + gdextension_file_absolute)
			return

		# Check if loaded (no need to call GDExtensionManager.load_extension)
		var extension: GDExtension = GDExtensionManager.get_extension(gdextension_file_absolute)
		if extension == null:
			push_error("[Main] The GDExtension library could not be loaded or does not exist at " + gdextension_file_absolute)
			return

		if not extension.is_library_open():
			push_error("[Main] The GDExtension library is not opened")
			return

	_check_existence("GDExample")
	load_new_scene.call_deferred("res://gdexample_inheritance.tscn")
	#load_new_scene.call_deferred("res://gdexample_as_child.tscn")


func load_new_scene(scn: String):
	var error: Error = get_tree().change_scene_to_file(scn)
	if error != OK:
		push_error("change_scene_to_file returned %d" % error)
	print("[Main] scene changed")


func find_files_with_extension(p_folder_path_absolute: String, p_extension: String) -> Array[String]:
	var files: Array[String] = []

	var dir = DirAccess.open(p_folder_path_absolute)
	if !dir:
		push_error("[Main] Failed to open directory %s with error %d" % [p_folder_path_absolute, DirAccess.get_open_error()])
		return files

	dir.include_hidden = false
	dir.include_navigational = false
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(p_extension):
			files.push_back(p_folder_path_absolute.path_join(file_name))
		file_name = dir.get_next()
	dir.list_dir_end()

	return files

func _check_existence(p_class: String):
	if ClassDB.class_exists(p_class):
		print("[Main] " + p_class + " class exists")
	else:
		print("[Main] " + p_class + " class does not exist")
