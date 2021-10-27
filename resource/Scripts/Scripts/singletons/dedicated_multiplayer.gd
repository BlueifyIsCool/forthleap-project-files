extends Node

var r;

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
# var ip = "192.168.1.7"
var port = 1024

var initial_client_time
var server_time
var client_recipient_time
var round_trip_time
var offset_estimate

func _ready():
	r = get_tree().connect("network_peer_connected", self, "player_connect")

func _process(_delta):
	pass
#---------------------------------------------------------------------------------
func HostServer():
	var net = NetworkedMultiplayerENet.new()
	net.create_server(port, 2)
	get_tree().set_network_peer(net)
	print("Hosting to Port ", port)
#---------------------------------------------------------------------------------
func ConnectToServer():
	var already_connected = false
	network.create_client(ip, port)
	get_tree().set_network_peer(null)
	get_tree().set_network_peer(network)
	
	if not already_connected:
		network.connect("connection_succeeded", self,"_Connection_Successful")
		network.connect("connection_failed", self, "_Connection_Failed")
		already_connected = true
#---------------------------------------------------------------------------------
func DisconnectToServer():
	get_tree().set_network_peer(null)
#---------------------------------------------------------------------------------
func sync_player_pos(pos, node_path, requester):
	rpc_id(1, "sync_player_pos", pos, $"/root/Test_World".get_child(node_path), get_tree().get_network_unique_id())
remote func set_synced_player_pos(s_pos, node_path):
	node_path.set_pos(s_pos)
#---------------------------------------------------------------------------------
func player_connect():
	rpc("player_connect")
remote func players_connected():
	var map = preload("res://resource/Scenes/Maps/multiplayer_world.tscn")
	SceneTransition.goto_scene(map)
#---------------------------------------------------------------------------------
func _Connection_Successful():
	print("Connection Successful!")
func _Connection_Failed():
	print("Connection Failed D:")
#---------------------------------------------------------------------------------


