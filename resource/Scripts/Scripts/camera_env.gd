extends Camera

var low_env = preload("res://resource/Graphics Presets/low.tres")
var medium_env = preload("res://resource/Graphics Presets/medium.tres")
var high_env = preload("res://resource/Graphics Presets/high.tres")

func _ready():
	if SaveSettings.graphics_pref == 1:
		environment = low_env
		print("Low environment quality set!")
	elif SaveSettings.graphics_pref == 2:
		environment = medium_env
		print("Medium environment quality set!")
	if SaveSettings.graphics_pref == 3:
		environment = high_env
		print("High environment quality set!")
