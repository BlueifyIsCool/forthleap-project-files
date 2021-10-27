extends Node

var r;
var fullscreen

func _ready():
	if SaveSettings.fullscreen != null:
		fullscreen = SaveSettings.fullscreen
	else:
		return
#---------------------------------------------------------------------------------
func _input(event) -> void:
	if GlobalAutoloadVariables.main_menu_resource_loaded:
		# Toggle Fullscreen
		if Input.is_action_pressed("toggle_fullscreen_button_1"):
			if Input.is_action_just_pressed("toggle_fullscreen_button_2"):
				OS.window_fullscreen = !OS.window_fullscreen
		# Exit Game
		if Input.is_action_just_pressed("toggle_pausemenu"):
			get_tree().quit()
		# Restart Scene
		if Input.is_action_just_pressed("restart_scene"):
			r = get_tree().reload_current_scene()
		if Input.is_action_just_pressed("debug"):
			print(GlobalAutoloadVariables.tutorial_dialogue)
#---------------------------------------------------------------------------------
