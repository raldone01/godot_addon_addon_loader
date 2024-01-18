@tool
extends EditorPlugin

var main_panel: Control
var addons_panel_manager: Variant

func _enter_tree() -> void:
	addons_panel_manager = load("res://addons/addon_loader/addons_shared_gen/addons_panel_manager.gd").AddonsPanelManager.new(self)
	main_panel = preload("res://addons/addon_loader/scenes_editor/ui_addon_panel.tscn").instantiate()
	addons_panel_manager.add_main_panel(main_panel)

func _exit_tree() -> void:
	addons_panel_manager.remove_main_panel()

func _get_plugin_name() -> String:
	return "addon_loader"
