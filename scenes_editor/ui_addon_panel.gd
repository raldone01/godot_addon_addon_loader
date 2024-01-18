@tool
extends Control

var addon_tools_script: Script = load("res://addons/addon_loader/funcs_editor/addon_tools.gd")

@onready
var button_reload_slected: Button = $%ButtonReloadSelected

@onready
var button_disable_selected: Button = $%ButtonDisableSelected

@onready
var button_reload_all_enabled: Button = $%ButtonReloadAllEnabled

@onready
var item_list_addons: ItemList = $%ItemListAddons

@onready
var button_select_all: Button = $%ButtonSelectAll

@onready
var button_refresh_addon_list: Button = $%ButtonRefreshAddonList

@onready
var item_list_addon_infos: Array[Dictionary] = []

func _ready() -> void:
	button_reload_slected.connect("pressed", _on_button_reload_slected_pressed)
	button_disable_selected.connect("pressed", _on_button_disable_selected_pressed)
	button_reload_all_enabled.connect("pressed", _on_button_reload_all_enabled_pressed)
	button_select_all.connect("pressed", _on_button_select_all_pressed)
	button_refresh_addon_list.connect("pressed", _on_button_refresh_addon_list_pressed)
	_update_addon_item_list()

func _on_button_reload_slected_pressed() -> void:
	var addon_infos: Array[Dictionary] = item_list_addon_infos

	for i in item_list_addons.get_selected_items():
		var addon_info: Dictionary = addon_infos[i]
		# even reload them when they are disabled but selected in the list
		addon_tools_script.reload_addon(addon_info["godot_display_name"], false)

func _on_button_disable_selected_pressed() -> void:
	var addon_infos: Array[Dictionary] = item_list_addon_infos

	for i in item_list_addons.get_selected_items():
		var addon_info: Dictionary = addon_infos[i]
		var godot_display_name: String = addon_info["godot_display_name"]
		EditorInterface.set_plugin_enabled(godot_display_name, false)

func _on_button_reload_all_enabled_pressed() -> void:
	var addon_infos: Array[Dictionary] = addon_tools_script.load_addon_infos_from_folder()

	EditorInterface.get_resource_filesystem().scan()
	EditorInterface.get_resource_filesystem().scan_sources()

	for addon_info in addon_infos:
		if is_addon_addon_loader(addon_info):
			continue
		var godot_display_name: String = addon_info["godot_display_name"]
		addon_tools_script.reload_addon(addon_info["godot_display_name"])

	# reload addon_loader last
	for addon_info in addon_infos:
		if not is_addon_addon_loader(addon_info):
			continue
		addon_tools_script.reload_addon(addon_info["godot_display_name"])

func _on_button_select_all_pressed() -> void:
	for i in range(item_list_addons.get_item_count()):
		item_list_addons.select(i, false)

func _on_button_refresh_addon_list_pressed() -> void:
	_update_addon_item_list()

func _update_addon_item_list() -> void:
	item_list_addons.clear()
	item_list_addon_infos.clear()

	var addon_infos: Array[Dictionary] = addon_tools_script.load_addon_infos_from_folder()

	for addon_info in addon_infos:
		if is_addon_addon_loader(addon_info):
			continue
		item_list_addons.add_item(addon_info["godot_display_name"], null, true)
		item_list_addon_infos.append(addon_info)

func is_addon_addon_loader(addon_info: Dictionary) -> bool:
	var godot_display_name: String = addon_info["godot_display_name"]
	return godot_display_name.contains("addon_loader")
