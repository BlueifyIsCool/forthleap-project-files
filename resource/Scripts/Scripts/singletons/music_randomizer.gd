extends AudioStreamPlayer

onready var tween_out

export var transition_duration = 1.00
export var transition_type = 1 # TRANS_SINE

var streamLength = ""

var song_playing = ""
var song_length
var song_number

var randomize_song = true

const tracks = [
	'ArtificialMusic - And So It Begins',
	'Danlsan - Free With You',
	'Dawn - Sappheiros',
	'Gravity - Extenzt',
	'LAKEY INSPIRED - Chill Day',
	'LAKEY INSPIRED - Me 2',
	'Sappheiros - Falling',
	'THBD - Lost In The Night',
	'Vorsa - If Only You Knew',
	]

func _ready():
	tween_out = $TweenOut
	randomize()
	volume_db = -25
	play_random_song()
	
func _process(_delta):
	if playing != false:
		if not randomize_song:
			fade_out(self)
	
func fade_out(stream_player):
	# tween music volume down to 0
	tween_out.interpolate_property(stream_player, "volume_db", -25, -80, transition_duration, transition_type, Tween.EASE_IN, 0)
	tween_out.start()
	# when the tween ends, the music will be stopped

func _on_TweenOut_tween_completed(object, _key):
	# stop the music -- otherwise it continues to run at silent volume
	object.stop()
	object.volume_db = -25

func play_random_song():
	randomize()
	if randomize_song:
		var rand_nb = randi() % tracks.size()
		var audiostream = load('res://resource/Audio/Music/' + tracks[rand_nb] + '.ogg')
		set_stream(audiostream)
		song_playing = stream.resource_path.get_file().get_basename()
		song_number = rand_nb
		play()
		streamLength = stream.get_length() / 60
		song_length = int(round(streamLength))
	pass
func _on_Node_finished():
	play_random_song()
