extends KinematicBody

var r;
var obj;
var obj_name;
#Loading
onready var map_loading = $map_loading
onready var frame_label = $map_loading/backround/Label
var already_deleted = false
var frame = 0
var max_frames
# Player Variables
var speed
var default_speed = 5
var sprinting_speed = 10
var sprinting_speed_on_wall = 8
var crouch_move_speed = 3.5
var crouching_speed = 5
var jump
var default_jump = 4
var sprinting_jump_height = 4.5
var jump_height_on_wall = 7.5
var gravity = 11
const ACCEL_DEFAULT = 20
const ACCEL_AIR = 100
onready var accel = ACCEL_DEFAULT
# Mouse / Camera Movement
var direction = Vector3()
var velocity = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()
var cam_accel = 1
var mouse_sense = 0.15
var snap
var camera_rotate_speed = 1
var velocity_speed = 0
var crouching_height = 0.05
var default_height = 1
var camera_tilt = 1
var camera_fov_default = 90
var camera_fov_max
var camera_fov_sliding = 120
var camera_fov_sprinting = 100
# Movement Conditions
var can_move = true
var can_sprint = true
var can_slide = true
var can_crouch = true
var can_jump = true
var can_climb = true
var can_move_camera = true
var head_hit = false
var crouching = false
var running = false
var sprinting = false
var sliding = false
var killed
var is_on_wall_2 = false
var ledgegrab_played = false
var walkSFXPlayed = false
var landing : bool
# Player Essentials
onready var mesh = $MeshInstance
onready var playerCollision = $CollisionShape
onready var head = $Head
onready var camera = $Head/Camera
# Detectors
onready var eye_raycast = $Head/aim_cast
onready var ceiling_raycast = $Raycasts/ceiling_checker
onready var left_ray = $Raycasts/left_raycast
onready var right_ray = $Raycasts/right_raycast
onready var ground_check = $Raycasts/check_ground
# Sound Effects
onready var walkSFX = $Audio/walk
onready var runSFX = $Audio/run
onready var fallSFX = $Audio/fall
onready var hitheadSFX = $Audio/head_hit
onready var deathSFX = $Audio/death
onready var jumpSFX = $Audio/jump
onready var grabledgeSFX = $Audio/grab_ledgeclimb
# Balance
onready var fall_timer = $Timers/fall_timer
onready var wall_jump_delay = $Timers/wall_jump_delay
onready var slide_stop = $Timers/slide_stop
var slide_stop_started = false
onready var slide_allow = $Timers/slide_allow
# Item Pickup
var can_pick_objects = true
var phys_area_object
var phys_area_object_name
onready var phys_area = $Head/obj_pickup
onready var phys_area_aim = $Head/obj_pickup/object_position
# Debug Resource
var can_debug = false
onready var debug_node = $debug
onready var can_move_label
onready var can_jump_label
onready var can_climb_label
onready var crouching_label
onready var sprinting_label
onready var wall_fall_label
onready var wall_jump_label
onready var game_fps_label
onready var physics_fps_label
onready var frame_time_label
onready var ram_usage_label
onready var vram_usage_label
onready var gpu_driver_label
onready var operating_system_label
onready var object_holding_label
onready var look_at_object_name_label

func _ready():
	randomize()
	max_frames = rand_range(35, 150)
	jump = default_jump
	map_loading.visible = true
	debug_node.visible = false
	can_debug = false
	set_physics_process(false)
	set_process_input(false)
	can_move_camera = false
	mesh.visible = false
	killed = false
	camera_fov_max = camera_fov_sprinting
	speed = default_speed
	# debug res
	can_move_label = $debug/ColorRect/can_move
	can_jump_label = $debug/ColorRect/can_jump
	can_climb_label = $debug/ColorRect/can_climb
	crouching_label = $debug/ColorRect/crouching
	sprinting_label = $debug/ColorRect/sprinting
	wall_fall_label = $debug/ColorRect/wall_fall
	wall_jump_label = $debug/ColorRect/wall_jump_delay
	game_fps_label = $debug/ColorRect/game_fps
	physics_fps_label = $debug/ColorRect/physics_fps
	frame_time_label = $debug/ColorRect/frame_time
	ram_usage_label = $debug/ColorRect/ram_usage
	vram_usage_label = $debug/ColorRect/vram_usage
	gpu_driver_label = $debug/logo/logo2
	operating_system_label = $debug/logo/logo3
	object_holding_label = $debug/ColorRect/object_holding
	look_at_object_name_label = $debug/ColorRect/look_at_object_name
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

remote func _set_position(pos):
	global_transform.origin = pos

func _input(event):
	#get mouse input for camera rotation
	if can_move_camera:
		if event is InputEventMouseMotion:
			rotate_y(deg2rad(-event.relative.x * mouse_sense))
			head.rotate_x(deg2rad(-event.relative.y * mouse_sense))
			head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))
	if Input.is_action_just_pressed("interact") and can_pick_objects:
		for body in phys_area.get_overlapping_bodies():
			if body is RigidBody:
				phys_area_object = body
				phys_area_object_name = body.name
				return
	if Input.is_action_just_released("interact"):
			phys_area_object = null
			phys_area_object_name = null
	if Input.is_action_just_pressed("left_click") and phys_area_object != null and weakref(phys_area_object).get_ref():
		var a = phys_area_aim.get_global_transform().origin
		var b = phys_area_object.get_global_transform().origin
		
		phys_area_object.set_linear_velocity((b-a)*8.5)
		phys_area_object = null
	if event.is_action_pressed("mouse_wheel_up") and phys_area_object != null and weakref(phys_area_object).get_ref():
		phys_area_object.rotation += Vector3(0.05, 0.05, 0.05)
	if event.is_action_pressed("mouse_wheel_down") and phys_area_object != null and weakref(phys_area_object).get_ref():
		phys_area_object.rotation -= Vector3(0.05, 0.05, 0.05)
	
	if Input.is_action_just_pressed("debug"):
		if GlobalAutoloadVariables.debug_on_off:
			debug_node.visible = !debug_node.visible
			can_debug = !can_debug
			
func _process(_delta):
	# debug stats
	var fps = Engine.get_frames_per_second()
	var frame_time = Performance.get_monitor(Performance.TIME_PROCESS) * 1000
	var physics_speed = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000
	var vram_usage = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
	var ram_usage = OS.get_static_memory_usage()
	var driver = OS.get_video_driver_name(OS.VIDEO_DRIVER_GLES3)
	var operating_system = OS.get_name()
	
	vram_usage = vram_usage/1000000
	ram_usage = ram_usage/1000000
	vram_usage = int(round(vram_usage))
	ram_usage = int(round(ram_usage))
	
	velocity_speed = velocity.length()
	velocity_speed = int(round(velocity_speed))
	
	camera.fov = clamp(camera.fov, camera_fov_default, camera_fov_max)
	mouse_sense = clamp(mouse_sense, 0.05, 1)
	GlobalAutoloadVariables.dead = killed
	GlobalAutoloadVariables.climbable = is_on_wall_2
	GlobalAutoloadVariables.speed = velocity_speed
	GlobalAutoloadVariables.fps = fps
	
	if GlobalAutoloadVariables.debug_on_off:
		if can_debug:
			can_move_label.set_text(str("can_move: ", can_move))
			can_jump_label.set_text(str("can_jump: ", can_jump))
			can_climb_label.set_text(str("can_climb: ", can_climb))
			crouching_label.set_text(str("crouching: ", crouching))
			sprinting_label.set_text(str("sprinting: ", sprinting))
			wall_fall_label.set_text(str("slip_on_wall_time_left: ", fall_timer.time_left ," Sec"))
			wall_jump_label.set_text(str("wall_jump_delay_time_left: ", wall_jump_delay.time_left, " Sec"))
			game_fps_label.set_text(str("game_fps: ", fps))
			physics_fps_label.set_text(str("physics_time: ", physics_speed ," MS"))
			frame_time_label.set_text(str("frame_time: ", frame_time ," MS"))
			ram_usage_label.set_text(str("ram_usage: ", ram_usage ," MB"))
			vram_usage_label.set_text(str("vram_usage: ", vram_usage," MB"))
			object_holding_label.set_text(str("object_holding_name: ", phys_area_object ,"; ", phys_area_object_name))
			look_at_object_name_label.set_text(str("look_at_object_name: ", obj ,"; ", obj_name))
			gpu_driver_label.set_text(str(driver))
			operating_system_label.set_text(str(operating_system))
		else:
			can_move_label.set_text("")
			can_jump_label.set_text("")
			can_climb_label.set_text("")
			crouching_label.set_text("")
			sprinting_label.set_text("")
			wall_fall_label.set_text("")
			wall_jump_label.set_text("")
			game_fps_label.set_text("")
			physics_fps_label.set_text("")
			frame_time_label.set_text("")
			ram_usage_label.set_text("")
			vram_usage_label.set_text("")
			object_holding_label.set_text("")
			look_at_object_name_label.set_text("")
			gpu_driver_label.set_text("")
			operating_system_label.set_text("")
		# this debug sht is very unoptimized
		
	# Loading code
	randomize()
	var already_rand = false
	if not already_rand:
		already_rand = true
	max_frames = int(round(max_frames))
	if frame < max_frames:
		frame += 1 
		frame_label.set_text(str(frame, " / ", max_frames))
	frame = clamp(frame, 0, max_frames)
	if frame == max_frames:
		if map_loading != null and not already_deleted:
			set_physics_process(true)
			set_process_input(true)
			$on_screen_gui.set_process(true)
			can_move_camera = true
			map_loading.queue_free()
			already_deleted = true
		
	if ceiling_raycast.is_colliding():
		can_jump = false
		head_hit = true
	else:
		can_jump = true
		head_hit = false
	
	# RUNNING STATE
	if sprinting:
		if is_on_floor():
			if not runSFX.is_playing():
				runSFX.play()
		if not is_on_floor():
			runSFX.stop()
	if not sprinting:
		if is_on_floor() and velocity.length() > 1:
			if not walkSFX.is_playing():
				walkSFX.play()
		if velocity.length() <= 0.9:
			walkSFX.stop()
		if not is_on_floor():
			walkSFX.stop()
	
	if velocity.length() > 5.5:
		camera_fov_max = camera_fov_sprinting
		camera.fov += 1
		sprinting = true
	if velocity.length() < 5.5:
		camera.fov -= 1
		sprinting = false
		
	if sprinting and walkSFX.is_playing():
		walkSFX.stop()
	if not sprinting and runSFX.is_playing():
		runSFX.stop()
		
	if is_on_floor():
		if landing:
			if not grabledgeSFX.is_playing():
				fallSFX.play()
			landing = false
			fallSFX.stop()
	else:
		if !landing: 
			landing = true
			
	
func _physics_process(delta):
	# Basic Movement
	direction = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	var h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	if Input.is_action_pressed("move_sprint"):
		running = true
		if is_on_wall_2:
			speed = sprinting_speed_on_wall
			jump = sprinting_jump_height
		else:
			speed = sprinting_speed
			jump =  sprinting_jump_height
	else:
		running = false
		speed = default_speed
		jump = 4
	
	# Object Pickup
	if phys_area_object != null and weakref(phys_area_object).get_ref():
		var a = phys_area.get_global_transform().origin
		var b = phys_area_object.get_global_transform().origin
		phys_area_object.set_linear_velocity((a-b)*10)
		if phys_area_object.get("timer") != null:
			phys_area_object.timer = 0
			
	# Check Ground
	if ground_check.is_colliding():
		can_pick_objects = true
	else:
		phys_area_object = null
		can_pick_objects = false
	# Detect and Get Name of OBJ in front of raycast
	if eye_raycast.is_colliding():
		var obj_collided = eye_raycast.get_collider()
		obj = obj_collided
		obj_name = obj_collided.get_name()
	else:
		obj = null
		obj_name = null
		
	if is_on_wall_2 and is_on_wall():
		if left_ray.is_colliding():
				camera.rotate_z(deg2rad(camera_tilt))
		if right_ray.is_colliding():
				camera.rotate_z(deg2rad(-camera_tilt))
	elif not is_on_wall():
		if left_ray.is_colliding():
			if camera.rotation.z > 0:
				camera.rotate_z(deg2rad(-camera_tilt * 0.5))
		else:
			if camera.rotation.z > 0:
				camera.rotate_z(deg2rad(-camera_tilt * 0.5))
		if right_ray.is_colliding():
				if camera.rotation.z < 0:
					camera.rotate_z(deg2rad(camera_tilt * 0.5))
		else:
			if camera.rotation.z < 0:
				camera.rotate_z(deg2rad(camera_tilt * 0.5))
					
	# Sliding
	if Input.is_action_pressed("Slide") and is_on_floor():
		if can_slide == true:
			sliding = true
			if sprinting:
				if slide_stop.time_left <= 0:
					slide_stop.start()
				playerCollision.shape.height -= crouching_speed * delta
				speed = sprinting_speed * 0.95
				camera.rotate_z(deg2rad(camera_tilt * 0.75))
		else:
			sliding = false
			if not head_hit:
				playerCollision.shape.height += crouching_speed * delta
			else:
				playerCollision.shape.height -= crouching_speed * delta
			if camera.rotation.z < 0:
				camera.rotate_z(deg2rad(camera_tilt * 0.5))
			if not running:
				speed = default_speed
	else:
		sliding = false
		if not head_hit:
			playerCollision.shape.height += crouching_speed * delta
		else:
			playerCollision.shape.height -= crouching_speed * delta
	
	# Crouching
	if Input.is_action_pressed("Crouch") and can_crouch:
		crouching = true
		can_sprint = false
		can_slide = false
		playerCollision.shape.height -= crouching_speed * delta
	elif not head_hit:
		crouching = false
		can_sprint = true
		if not running:
			can_slide = true
		
	if crouching:
		speed = crouch_move_speed
	elif not running:
		speed = default_speed
		
	playerCollision.shape.height = clamp(playerCollision.shape.height, crouching_height, default_height)
	
	camera.rotation.z = clamp(0 , -0.05, 0.05)
	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	#jumping and gravity
	if is_on_floor():
		snap = -get_floor_normal()
		accel = ACCEL_DEFAULT
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
	
	if Input.is_action_pressed("move_jump") and is_on_floor():
		if can_jump:
			snap = Vector3.ZERO
			gravity_vec = Vector3.UP * jump
			if not jumpSFX.is_playing():
				jumpSFX.play()
			
	#make it move
	velocity = velocity.linear_interpolate(direction * speed, accel * delta)
	movement = velocity + gravity_vec
	
	r = move_and_slide_with_snap(movement, snap, Vector3.UP)
	
func dead():
	killed = true 
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	if walkSFX.is_playing():
		walkSFX.stop()
	if runSFX.is_playing():
		runSFX.stop()
	set_physics_process(false)
	can_move_camera = false
	$on_screen_gui.visible = false
	$death_screen.visible = true
	
func _on_Hurtbox_area_entered(area):
	if area.get_name() == "Underdeath":
		dead()
		killed = true
		deathSFX.play()
	if area.get_name() == "tutorial_area_1":
		GlobalAutoloadVariables.tutorial_dialogue = "Press 'SPACE' to JUMP."
	if area.get_name() == "tutorial_area_2":
		GlobalAutoloadVariables.tutorial_dialogue = "To SPRINT simply hold 'SHIFT', combining SPRINTING with JUMPING makes you even faster."
	if area.get_name() == "tutorial_area_3":
		GlobalAutoloadVariables.tutorial_dialogue = "To WIN, just reach the end without dying. GOOD LUCK!"
func _on_WinBox_area_entered(area):
	if area.get_name() == "WinArea":
		r = get_tree().change_scene("res://game_scenes/level_pick.tscn")

func _on_fall_timer_timeout():
	can_climb = false
	gravity = 11
	if wall_jump_delay.time_left <= 0:
		wall_jump_delay.start()
	
func _on_wall_jump_delay_timeout():
	can_climb = true
	
func _on_slide_stop_timeout():
	can_slide = false
	if slide_allow.time_left <= 0:
		slide_allow.start()
func _on_slide_allow_timeout():
	can_slide = true
