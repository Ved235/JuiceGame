# camera_manager.gd
extends Control

@export var target_path: NodePath
@export var top_camera: Camera3D
@export var left_camera: Camera3D
@export var right_camera: Camera3D


# References to viewports - updated paths to match new layout
@onready var left_viewport: SubViewport = $VBoxContainer/TopRowContainer/LeftViewContainer/LeftViewport
@onready var right_viewport: SubViewport = $VBoxContainer/TopRowContainer/RightViewContainer/RightViewport
@onready var top_viewport: SubViewport = $VBoxContainer/TopViewContainer/TopViewport

func _ready():
	var target = get_node(target_path) if target_path else null
	print("Target found: ", target != null)
	
	# Setup top camera
	if top_camera:
		setup_viewport_camera(top_camera, top_viewport, "top", target)
	
	# Setup left camera
	if left_camera:
		setup_viewport_camera(left_camera, left_viewport, "left", target)
	
	# Setup right camera
	if right_camera:
		setup_viewport_camera(right_camera, right_viewport, "right", target)
	
	# Optionally, hide the original cameras
	if top_camera: top_camera.visible = false
	if left_camera: left_camera.visible = false
	if right_camera: right_camera.visible = false


func setup_viewport_camera(original_camera: Camera3D, viewport: SubViewport, view_type_name: String, target: Node):
	# Create a new camera for the viewport
	var viewport_camera = Camera3D.new()
	
	# Copy transform
	viewport_camera.transform = original_camera.transform
	
	# Load and set the script directly (don't rely on the original camera having it)
	var camera_script = load("res://fixed_camera.gd")
	viewport_camera.set_script(camera_script)
	
	# Add to viewport first
	viewport.add_child(viewport_camera)
	
	# Important: We're using call_deferred to ensure the camera is fully
	# added to the scene tree before configuring it
	if target:
		viewport_camera.call_deferred("configure_camera", view_type_name, target)
