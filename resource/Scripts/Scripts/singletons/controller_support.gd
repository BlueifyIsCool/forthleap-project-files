extends Control

var r;
var controller_sens = 500.0

func _ready():
	r = Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	#Checks what status is right now
	if Input.get_connected_joypads().size() == 0:
		$"/root/ControllerSupport/CanvasLayer/Sprite".visible = false
	else:
		#Gets controller type
		print(Input.get_joy_name(Input.get_connected_joypads()[0]))
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		$"/root/ControllerSupport/CanvasLayer/Sprite".visible = true
		
#---------------------------------------------------------------------------------
func _on_joy_connection_changed(device_id, connected):
	if connected:
		print(Input.get_joy_name(device_id))
	else:
		print("Keyboard")
#---------------------------------------------------------------------------------
func _physics_process(delta):
	$"/root/ControllerSupport/CanvasLayer/Sprite".position = get_global_mouse_position()
	var direction : Vector2
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
#---------------------------------------------------------------------------------
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
	var movement = controller_sens * direction * delta
	if (movement):  
		get_viewport().warp_mouse(get_global_mouse_position() + movement) 
#---------------------------------------------------------------------------------
func _left_click():
	var a = InputEventMouseButton.new()
	a.button_index = BUTTON_LEFT
	a.position = get_viewport().get_mouse_position()
	a.pressed = true
	Input.parse_input_event(a)
	a.pressed = false
	Input.parse_input_event(a)
