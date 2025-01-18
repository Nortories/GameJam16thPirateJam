extends CharacterBody3D

@export var MOUSE_SENS: float = 0.005
@export var gravity: float = -3.0
@export var speed: float = 30.0
@export var jump_strength: float = 50.0
@export var max_jump_amt: int = 3
@export var max_dash_amt: int = 3
@export var extra_vel_multi: float = 400.0
@export var min_fov: float = 125.0

var ang_for_cam_to_lerp_to: float = 0.0
var x_ang_for_cam_to_lerp_to: float = 0.0
var velocity_3d: Vector3 = Vector3.ZERO
var y_speed: float = 0.0
var jump_num: int = 0
var dash_num: int = 0
var extra_velocity: Vector3 = Vector3.ZERO
var target_fov: float = 0.0
var fov_timer: float = 10.0
var fov_duration: float = .45

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	target_fov = $head/Camera.fov
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		$head.rotation.x += -event.relative.y * MOUSE_SENS
		rotation.y += -event.relative.x * MOUSE_SENS
		$head.rotation.x = clamp($head.rotation.x, deg_to_rad(-90), deg_to_rad(90)) # Prevent head flipping

func jump() -> void:
	jump_num += 1
	y_speed = jump_strength

func dash_forward() -> void:
	dash_num += 1
	print(sign(y_speed))
	if sign(y_speed) == -1:
		y_speed = 0
	extra_velocity += -$head/Camera.global_transform.basis.z * extra_vel_multi
	fov()

func _physics_process(delta: float) -> void:
	velocity_3d = get_dir().rotated(Vector3.UP, rotation.y) * speed

	if not is_on_floor():
		y_speed += gravity
	else:
		y_speed = 0.0
		dash_num = 0
		jump_num = 0

	if Input.is_action_just_pressed("ui_dash") and jump_num < max_jump_amt:
		jump()
	if Input.is_action_just_pressed("ui_jump") and dash_num < max_dash_amt:
		dash_forward()

	$head.rotation_degrees.z = lerp($head.rotation_degrees.z, ang_for_cam_to_lerp_to, 0.1)
	$head/Camera.rotation_degrees.x = lerp($head/Camera.rotation_degrees.x, x_ang_for_cam_to_lerp_to, 0.1)
	extra_velocity = lerp(extra_velocity, Vector3.ZERO, 0.1)

	velocity_3d.y = y_speed
	velocity_3d += extra_velocity
	velocity = velocity_3d
	move_and_slide()
	
	# Gradually change FOV
	if fov_timer < fov_duration:
		fov_timer += delta
		if fov_timer < fov_duration / 2:
			$head/Camera.fov = lerp(target_fov, min_fov, fov_timer / (fov_duration / 2))
		else:
			$head/Camera.fov = lerp(min_fov, target_fov, (fov_timer - fov_duration / 2) / (fov_duration / 2))
			
func fov() -> void:
	fov_timer = 0

func get_dir() -> Vector3:
	var dir: Vector3
	dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	dir.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	ang_for_cam_to_lerp_to = dir.x * -2.5
	x_ang_for_cam_to_lerp_to = dir.z * 7.5
	return dir.normalized()
