extends Node

var vsync
var borderless 
var fullscreen 
var graphics_pref

var settings_dict

var graphics_preset

func _ready():
	load_settings()
	read_gp_json()

func load_settings():
	var save_file = File.new()
	if not save_file.file_exists("user://settings.json"):
		vsync = 1
		borderless = 0
		fullscreen = 0
		graphics_pref = 2
		return
	
	save_file.open("user://settings.json", File.READ)
	var settings_dict_json = save_file.get_as_text()
	var settings_dict_get_result = JSON.parse(settings_dict_json)
	var settings_dict_result = settings_dict_get_result.result
	settings_dict = settings_dict_result
	vsync = settings_dict["vsync"]["value"]
	borderless = settings_dict["borderless"]["value"]
	fullscreen = settings_dict["fullscreen"]["value"]
	graphics_pref = settings_dict["graphics_pref"]["value"]
	print("Settings Loaded!")
	save_file.close()
	
func save_settings():
	var save_file = File.new()
	settings_dict = {
		"vsync": {
			"value": vsync
		},
		"fullscreen": {
			"value": fullscreen
		},
		"borderless": {
			"value": borderless
		},
		"graphics_pref": {
			"value": graphics_pref
		}
	}
	save_file.open("user://settings.json", File.WRITE)
	save_file.store_line(JSON.print(settings_dict))
	print("Settings Saved!")
	save_file.close()
	
func read_gp_json():
	var file = File.new()
	if file.open("res://graphics_presets.json", File.READ) != OK:
		return
	var json = file.get_as_text()
	file.close()
	
	var json_result = JSON.parse(json)
	if not json_result.error != OK:
		print("Graphics Presets Loaded!")
	else:
		print("Error getting presets!")
		return
		
	var json_data = json_result.result
	graphics_preset = json_data
