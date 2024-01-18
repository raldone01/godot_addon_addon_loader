const ADDONS_PATH: String = "res://addons/"

## Generates an array of godot addon display names and the respective folder paths.
##
## The returned array contains dictionaries with the following keys:
##
## - folder_path: The path to the addon folder.
## - display_name: The addon display name as defined in the plugin.cfg file.
## - folder_name: The name of the addon folder.
## - godot_display_name: The display name that will be used in the editor.
##
## Note:
## Godot uses the addon display name directly but if there are multiple addons with the same display name
## it will use the following pattern: "<addon_display_name> (<folder_name>)"
## Adapted from: https://gist.github.com/Ryhon0/c8c051d8af191e7039a4bc260ea85c85 and https://github.com/godot-extended-libraries/godot-plugin-refresher/blob/master/addons/godot-plugin-refresher/plugin_refresher.gd
static func load_addon_infos_from_folder() -> Array[Dictionary]:
	# This dictionary collects all folder names for each addon display name.
	var addon_display_names := {}

	var dir := DirAccess.open(ADDONS_PATH)
	dir.list_dir_begin()
	while true:
		var addon_folder_name := dir.get_next()
		if addon_folder_name == "":
			break
		if not dir.current_is_dir():
			continue # not a folder

		# load the actual addon name from the plugin.cfg file
		var addon_config_path := ADDONS_PATH + "/" + addon_folder_name + "/plugin.cfg"
		if not FileAccess.file_exists(addon_config_path):
			continue # not an addon
		var addon_cfg := ConfigFile.new()
		addon_cfg.load(addon_config_path)

		var addon_display_name := addon_cfg.get_value("plugin", "name", addon_folder_name)
		var dependencies := addon_cfg.get_value("plugin", "dependencies", [])

		var addon_info := {
			"folder_path": ADDONS_PATH + "/" + addon_folder_name,
			"display_name": addon_display_name,
			"folder_name": addon_folder_name,
			"godot_display_name": addon_display_name, # this will be changed if there is a collision later on
			"dependencies": dependencies
		}

		if not addon_display_names.has(addon_display_name):
			addon_display_names[addon_display_name] = []
		addon_display_names[addon_display_name].append(addon_info)
	dir.list_dir_end()

	# The array containing dictionaries.
	var addons_ret: Array[Dictionary] = []

	# Iterate over addon_display_names and handle display name collisions.
	for addon_display_name in addon_display_names:
		var addon_infos: Array = addon_display_names[addon_display_name]
		if addon_infos.size() == 1:
			# No collision, just add the addon info.
			addons_ret.append(addon_infos[0])
		else:
			# Collision, add the addon info with the folder name appended.
			for addon_info in addon_infos:
				addon_info["godot_display_name"] = "%s (%s)" % [addon_display_name, addon_info["folder_name"]]
				addons_ret.append(addon_info)

	return addons_ret

## Adapted from: https://gist.github.com/Ryhon0/c8c051d8af191e7039a4bc260ea85c85 and https://github.com/godot-extended-libraries/godot-plugin-refresher/blob/master/addons/godot-plugin-refresher/plugin_refresher.gd
static func reload_addon(p_godot_display_name: String, p_only_reload_if_enabled := true) -> void:
	print("Reloading addon: ", p_godot_display_name)

	var enabled := EditorInterface.is_plugin_enabled(p_godot_display_name)
	if enabled: # can only disable an active plugin
		EditorInterface.set_plugin_enabled(p_godot_display_name, false)

	if enabled or not p_only_reload_if_enabled:
		EditorInterface.set_plugin_enabled(p_godot_display_name, true)
