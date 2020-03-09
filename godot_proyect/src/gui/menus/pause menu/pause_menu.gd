extends MenuPanel
# Pause Menu.

const YESNO_MENU = preload("res://src/gui/menus/yesno menu/yesno_menu.tscn")

# Scenes.
const SELECT_SCREEN = "res://src/rooms/select stage/select_stage.tscn"
const TITLE_SCREEN = "res://src/rooms/title screen/title_screen.tscn"

export(Array, bool) var require_confirmation
var confirmation_status: bool = false

func _on_action_pressed_ui_accept():
	if needs_confirmation():
		# Wait for the yesno menu to confirm the action.
		var status = wait_confirmation()
		if status is GDScriptFunctionState:
			yield(status, "completed")
		if !confirmation_status:
			set_active(true)
			return
	match entry_index:
		0: # Resume.
			# Unpause the game.
			global.set_user_pause(false)
		1: # Settings.
			# TODO: Open Settings menu.
			pass
		2: # Exit Stage.
			# Load the stage select scene.
			get_tree().change_scene(SELECT_SCREEN)
			global.set_user_pause(false)
		3: # Exit to Title Screen.
			get_tree().change_scene(TITLE_SCREEN)
			global.set_user_pause(false)
		4: # Exit to Desktop.
			# Close the game.
			global.exit_game()

func _on_confirmation_received(confirmed: bool) -> void:
	confirmation_status = confirmed

func needs_confirmation(entry: int = entry_index) -> bool:
	return require_confirmation[entry] if len(require_confirmation) > entry else true

func wait_confirmation(entry: int = entry_index) -> void:
	set_active(false)
	var inst = YESNO_MENU.instance()
	inst.palette = palette
	inst.connect("actioned", self, "_on_confirmation_received")
	get_parent().add_child(inst)
	yield(inst, "actioned")
