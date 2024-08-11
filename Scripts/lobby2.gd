extends Node

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 4

@onready var text_edit := $VBoxContainer/TextEdit
var players : Dictionary = {}
var player_info : Dictionary = {"name": "Name"}
var players_loaded : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta : float) -> void:
	#pass

#create_game
func _on_button_host_pressed() :
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		print("error :" + error)
		return error
	multiplayer.multiplayer_peer = peer

	players[1] = player_info
	player_connected.emit(1, player_info)
	print(player_info)
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")


#join_game
func _on_button_join_pressed(address : String = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		print("error :" + error)
		return error	
	print("peer :" + str(peer))
	multiplayer.multiplayer_peer = peer

func remove_multiplayer_peer() -> void :
	multiplayer.multiplayer_peer = null

# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func load_game(game_scene_path : String = "res://Scenes/Game.tscn" ) -> void:
	get_tree().change_scene_to_file(game_scene_path)

# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded() -> void :
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			$/root/Game.start_game()
			players_loaded = 0

# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id : int) -> void :
	_register_player.rpc_id(id, player_info)


@rpc("any_peer", "reliable")
func _register_player(new_player_info) -> void:
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)


func _on_player_disconnected(id : int) -> void:
	players.erase(id)
	player_disconnected.emit(id)

func _on_connected_ok() -> void :
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)


func _on_connected_fail() -> void :
	multiplayer.multiplayer_peer = null


func _on_server_disconnected() -> void :
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()


func _on_text_edit_text_changed() -> void :
	player_info["name"] = text_edit.get_text()
