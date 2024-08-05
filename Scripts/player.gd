extends CharacterBody2D

@onready var cam = $Camera2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	#cam.current = is_multiplayer_authority()
	return

func _physics_process(delta : float) ->void :
	# enleve le controle au gens qui ne sont pas connecte a son perso
	#if is_multiplayer_authority():
	if true:
		#esc the game
		# changer l'input
		if Input.is_action_just_pressed("quit"):
			#changer le chemin
			$"../".exit_game(name.to_int())
			get_tree().quit()
		
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta

		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		move_and_slide()
		return

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	return
