extends CharacterBody2D

@export var movement_data : PlayerMovementData

var air_jump = false
var just_wall_jumped = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var was_wall_normal = Vector2.ZERO

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var starting_position = global_position
@onready var wall_jump_timer = $WallJumpTimer

func _physics_process(delta): # Where to call all functions of the character
	apply_gravity(delta)
	handle_jump()
	handle_wall_jump()
	var input_axis = Input.get_axis("move_left", "move_right")
	handle_acceleration(input_axis, delta)
	handle_air_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	apply_air_resistance(input_axis, delta)
	update_animations(input_axis)
	var was_on_floor = is_on_floor()
	var was_on_wall = is_on_wall_only()
	if was_on_wall:
		was_wall_normal = get_wall_normal()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
	just_wall_jumped = false
	var just_left_wall = was_on_wall and not is_on_wall_only()
	if just_wall_jumped:
		wall_jump_timer.start()


func apply_gravity(delta): # Applies gravity to the character
	if not is_on_floor():
		velocity.y += gravity * movement_data.GRAVITY_SCALE * delta

func handle_wall_jump(): # Gives the ability to wall jump
	if not is_on_wall_only() and wall_jump_timer.time_left <= 0.0: return
	var wall_normal = get_wall_normal()
	if wall_jump_timer.time_left > 0.0:
		wall_normal = was_wall_normal
	if Input.is_action_just_pressed("jump"):
		velocity.x = wall_normal.x * movement_data.SPEED
		velocity.y = movement_data.JUMP_VELOCITY
		just_wall_jumped = true
		
func handle_jump(): # Gives the ability to jump and double-jump
	if is_on_floor(): air_jump = true
	
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = movement_data.JUMP_VELOCITY
	elif not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < movement_data.JUMP_VELOCITY / 2:
			velocity.y = movement_data.JUMP_VELOCITY / 2
			
		if Input.is_action_just_pressed("jump") and air_jump and not just_wall_jumped:
			velocity.y = movement_data.JUMP_VELOCITY * 0.8
			air_jump = false

func apply_friction(input_axis, delta): # Handles the speed at which the character stops and changes direction
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.FRICTION * delta)

func apply_air_resistance(input_axis, delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.AIR_RESISTANCE * delta)

func handle_acceleration(input_axis, delta): # Handles the acceleration of speed of the character while on floor
	if not is_on_floor(): return 
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.SPEED * input_axis, movement_data.ACCElERATION * delta)

func handle_air_acceleration(input_axis, delta): # Handles the acceleration of speed of the character while in the air
	if is_on_floor(): return
	if input_axis !=0:
		velocity.x = move_toward(velocity.x, movement_data.SPEED * input_axis, movement_data.AIR_ACCELERATION * delta)

func update_animations(input_axis): # Plays the correct animation based on the state of the character
	if input_axis !=0:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	
	if not is_on_floor():
		animated_sprite_2d.play("jump")


func _on_hazard_detector_area_entered(_area): # Resets the player to the starting position after entering the hazard zone
	LevelTransition.fade_to_black() 
	global_position = starting_position
	LevelTransition.fade_from_black()
