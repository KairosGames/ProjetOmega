class_name PlayerController extends OSCReceiver

var x: float = -500
var y: float = -500
var button: bool = false

var previous_messages := {}

func _ready() -> void:
	target_server = get_tree().get_root().find_child("ControllersServer", true, false)

func _process(_delta):
	if target_server.incoming_messages.has(osc_address):
		if x != target_server.incoming_messages[osc_address][0]:
			x = target_server.incoming_messages[osc_address][0]
		
		if y != target_server.incoming_messages[osc_address][1]:
			y = target_server.incoming_messages[osc_address][1]

func get_vector() -> Vector2:
	return Vector2(x, y)

func is_action_just_pressed() -> bool:
	if target_server == null or not target_server.incoming_messages.has(osc_address):
		return false
	
	var message = target_server.incoming_messages[osc_address]
	var pressed = message[2]
	
	var just_pressed: bool = pressed and not previous_messages.get(osc_address, false)
	previous_messages[osc_address] = pressed
	
	return just_pressed