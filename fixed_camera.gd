# fixed_camera.gd
extends Camera3D

@export var target_path: NodePath
@export var offset := Vector3(0, 5, 10)  # x = side offset, y = height, z = distance
@export var view_type := "top"  # top, left, right, back

var target: Node3D

func _ready():
	print("Camera ready")
	if target_path:
		target = get_node(target_path)
		print("Camera view type: ", view_type, " Target found: ", target != null)

# Called directly by camera_manager to set up the camera
func configure_camera(new_view_type: String, new_target: Node3D):
	print("Configuring camera: ", new_view_type)
	view_type = new_view_type
	target = new_target
	print("Camera configured with view type: ", view_type, " Target set: ", target != null)

func _process(_delta):
	if target:
		match view_type:
			"top":
				# Position above the player
				global_position = target.global_position + Vector3(0, offset.y, 0)
				# Look down at player
				look_at(target.global_position, Vector3.FORWARD)
			"left":
				# Position to the left of player with slight z offset to avoid alignment
				global_position = target.global_position + Vector3(-offset.x, offset.y/3, -0.1)
				# Look at player from the left
				look_at(target.global_position, Vector3.UP)
			"right":
				# Position to the right of player with slight z offset to avoid alignment
				global_position = target.global_position + Vector3(offset.x, offset.y/3, -0.1)
				# Look at player from the right
				look_at(target.global_position, Vector3.UP)
