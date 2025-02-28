# fixed_camera_player.gd
extends CharacterBody3D

@export_group("Movement")
## Character maximum run speed on the ground in meters per second.
@export var move_speed := 8.0
## Ground movement acceleration in meters per second squared.
@export var acceleration := 20.0
## When the player is on the ground and presses the jump button, the vertical
## velocity is set to this value.
@export var jump_impulse := 12.0
## Player model rotation speed in arbitrary units.
@export var rotation_speed := 12.0
## Minimum horizontal speed on the ground.
@export var stopping_speed := 1.0

var _gravity := -30.0
var _was_on_floor_last_frame := true

## The last movement direction input by the player.
@onready var _last_input_direction := global_basis.z
@onready var _start_position := global_position

@onready var _skin: SophiaSkin = %SophiaSkin
@onready var _dust_particles: GPUParticles3D = %DustParticles
@onready var _landing_sound: AudioStreamPlayer3D = %LandingSound
@onready var _jump_sound: AudioStreamPlayer3D = %JumpSound

func _ready() -> void:
	Events.kill_plane_touched.connect(func on_kill_plane_touched() -> void:
		global_position = _start_position
		velocity = Vector3.ZERO
		_skin.idle()
		set_physics_process(true)
	)
	Events.flag_reached.connect(func on_flag_reached() -> void:
		set_physics_process(false)
		_skin.idle()
		_dust_particles.emitting = false
	)

func _physics_process(delta: float) -> void:
	# Calculate movement input using world-aligned controls
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down", 0.4)
	
	# Map the 2D input to 3D world directions
	var move_direction := Vector3.ZERO
	move_direction.x = raw_input.x  # Left/right
	move_direction.z = raw_input.y  # Forward/backward
	move_direction = move_direction.normalized()
	
	# Orient the character
	if move_direction.length() > 0.2:
		_last_input_direction = move_direction.normalized()
	var target_angle := Vector3.BACK.signed_angle_to(_last_input_direction, Vector3.UP)
	_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)

	# Apply gravity and handle movement
	var y_velocity := velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	if is_equal_approx(move_direction.length_squared(), 0.0) and velocity.length_squared() < stopping_speed:
		velocity = Vector3.ZERO
	velocity.y = y_velocity + _gravity * delta
	
	# Handle jump
	var is_just_jumping := Input.is_action_just_pressed("jump") and is_on_floor()
	if is_just_jumping:
		velocity.y = jump_impulse
		_skin.jump()
		_jump_sound.play()
		
	# Handle animations and effects
	var ground_speed := Vector2(velocity.x, velocity.z).length()
	if !is_just_jumping:
		if not is_on_floor() and velocity.y < 0:
			_skin.fall()
		elif is_on_floor():
			if ground_speed > 0.0:
				_skin.move()
			else:
				_skin.idle()
				
	# Handle dust particles
	_dust_particles.emitting = is_on_floor() && ground_speed > 0.0
	
	# Handle landing sound
	if is_on_floor() and not _was_on_floor_last_frame:
		_landing_sound.play()
	
	_was_on_floor_last_frame = is_on_floor()
	
	# Apply movement
	move_and_slide()
