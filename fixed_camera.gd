extends Camera3D

@export var target_path: NodePath
@export var offset := Vector3(10, 5, 10)  # x = side offset, y = height, z = distance
@export var view_type := "top"  # top, left, right, front
@export var ortho_size := 7  # Controls the zoom level for orthographic cameras

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
	projection = Camera3D.PROJECTION_ORTHOGONAL
	size = ortho_size  # This controls how much is visible
	print("Camera configured with view type: ", view_type, " Target set: ", target != null)

func _process(_delta):
	if target:
		var target_transform = target.global_transform
		
		match view_type:
			"left":
				# Position to the left of the player based on player's orientation
				# Calculate position in a circle around the player
				var angle = -target.get_child(1).rotation.y
				var pos_x = target.global_position.x + cos(angle) * offset.x
				var pos_z = target.global_position.z + sin(angle) * offset.x
				global_position = Vector3(pos_x, target.global_position.y + offset.y/3, pos_z)
				# Look at player from the left
				look_at(target.global_position, Vector3.UP)
				
			"right":
				# Position to the right of the player based on player's orientation
				# Calculate position in a circle around the player
				var angle = -target.get_child(1).rotation.y -PI
				var pos_x = target.global_position.x + cos(angle) * offset.x
				var pos_z = target.global_position.z + sin(angle) * offset.x
				global_position = Vector3(pos_x, target.global_position.y + offset.y/3, pos_z)
				# Look at player from the right
				look_at(target.global_position, Vector3.UP)
				
			"top":
				# Top view doesn't rotate with the player, so keep a fixed downward look
				global_position = target_transform.origin + Vector3(0, offset.y, 0)
				look_at(target_transform.origin, Vector3.FORWARD)
