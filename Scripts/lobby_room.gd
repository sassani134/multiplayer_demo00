extends Control

@onready var text_edit = $VBoxContainer/TextEdit
var peer := ENetMultiplayerPeer.new()
@export var player_scene : PackedScene

func del_palyer(id : int) -> void :
	rpc("_del_player", id)
	return
	
@rpc("any_peer","call_local")
func _del_player(id : int) -> void:
	get_node(str(id)).queue_free()

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
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float) -> void:
	pass


func _on_button_host_pressed() ->void:
	peer.create_server(1027)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	add_player()
	#get_tree().change_scene("res://Game.tscn")
	return


func _on_button_join_pressed() ->void:
	peer.create_client("127.0.0.1", 1027)
	multiplayer.multiplayer_peer = peer
	#get_tree().change_scene("res://Game.tscn")
	## je ne dois pas ajouter un player aussi ?
	return
