extends Node

var game_version = "0.0.1050"

var env = 2

var playerName

var main_menu_resource_loaded = false

var player1id
var player2id = 1
var online = false

var r;
# STATS
var last_time = ""
var trigger_timer_state = 0
# PLAYER PREFERENCE
var debug_on_off = true
var sensitivity 
# PLAYER
var dead = false
var tutorial_dialogue = ""
var fps
var speed
#---------------------------------------------------------------------------------
func _ready():
	randomize()
	playerName = rand_range(1, 9999)
	playerName = round(playerName)
	playerName = str(playerName)
	
func _process(delta):
	var what = 0
	var cool = 0
	var hot = 0
	what += delta
	cool += delta
	hot += delta


