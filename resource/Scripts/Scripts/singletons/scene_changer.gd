extends Node

var followingScene = ""
var currentScene = ""

onready var root = $"/root"
var ThreadHandler
onready var player = $AnimationPlayer
onready var loading_frame = $CanvasLayer/LoadingFrame

func _ready():
	ThreadHandler = preload("res://resource/Scripts/singletons/ThreadHandler.gd").new()
	# Call after you instance the class to start the thread.
	ThreadHandler.start()
	currentScene = root.get_child(root.get_child_count() - 1)
	player.play("fade_out")
	
func goto_scene(path):
	GlobalAutoloadVariables.tutorial_dialogue = ""
	SceneTransition.followingScene = path
	player.playback_speed = 2
	player.play_backwards("fade_out")
	
func _process_scene(path):
	# It is now safe to remove the current scene
	currentScene.free()

	# Load the new scene.
	print(path)
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	currentScene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(currentScene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(currentScene)
	
	player.play("fade_out")
		
func _on_AnimationPlayer_animation_finished(_anim_name):
	if SceneTransition.followingScene != "" and followingScene != null:
		_process_scene(SceneTransition.followingScene)
	SceneTransition.followingScene = ""
