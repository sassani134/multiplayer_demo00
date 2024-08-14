extends Control

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id : int, player_info)
signal player_disconnected(peer_id : int)
signal server_disconnected

const PORT = 7000
const LOCALHOST = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players : Dictionary = {}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info : Dictionary = {"name": "Name"}

var players_loaded : int = 0

@onready var text_edit = $VBoxContainer/TextEdit
var peer := ENetMultiplayerPeer.new()

# ¿ Ressources qui a une PackedScene image son ... pour une selection ?
@export var player_scene : PackedScene
@export var map_scene : PackedScene

func del_palyer(id : int) -> void :
	rpc("_del_player", id)
	return
	
@rpc("any_peer","call_local")
func _del_player(id : int) -> void:
	get_node(str(id)).queue_free()
	return

func add_player(id : int = 1) -> void:
	## instantiate in the next scene
	var player := player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
	return

func exit_game(id : int) -> void :
	multiplayer.peer_disconnected.connect(del_palyer)
	del_palyer(id)
	return


# Called when the node enters the scene tree for the first time.
func _ready()-> void:
	#multiplayer.peer_connected.connect(_on_player_connected)
	#multiplayer.peer_disconnected.connect(_on_player_disconnected)
	#multiplayer.connected_to_server.connect(_on_connected_ok)
	#multiplayer.connection_failed.connect(_on_connected_fail)
	#multiplayer.server_disconnected.connect(_on_server_disconnected)
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float) -> void:
	return


func _on_button_host_pressed():# ¿ retournez l'erreur ou rien ?
	var error = peer.create_server(PORT, MAX_CONNECTIONS)#1027 port tuto prece
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	#
	multiplayer.peer_connected.connect(add_player)
	add_player()
	#essentielement la meme chose 
	players[1] = player_info
	player_connected.emit(1, player_info)

	#get_tree().change_scene("res://Game.tscn")
	return


func _on_button_join_pressed() :# ¿ retournez l'erreur ou rien ?
	var error = peer.create_client(LOCALHOST, PORT) #1027 port tuto prece
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	#get_tree().change_scene("res://Game.tscn")
	## je ne dois pas ajouter un player aussi ?
	

func empty_name() -> bool:
	if text_edit.text == null:
		return false
	else:
		return true
