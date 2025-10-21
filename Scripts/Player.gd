class_name Player extends Node2D

@export var collision_shape: CollisionShape2D
@export var arrow: Node2D
@export var grapple: Line2D
@export var raycast: RayCast2D

@export var starting_speed: float = 250#150.0
@export var shoot_dist: float = 100.0

var screen_size: Vector2
var speed: Vector2
var actual_speed: float
var radius: float

var aim_vec: Vector2 = Vector2.ZERO
var is_free: bool = true
var can_shoot: bool = true


func _ready() -> void:
	actual_speed = starting_speed
	speed = Vector2.RIGHT.rotated(randf() * TAU) * actual_speed
	screen_size = get_viewport_rect().size
	if collision_shape.shape is CircleShape2D:
		radius = collision_shape.shape.radius


func _process(delta: float) -> void:
	get_inputs()


func _physics_process(delta: float) -> void:
	if is_free:
		global_position += speed * delta
		rotate_viewfinder()
	else:
		pass
	rectify_position()


func get_inputs():
	aim_vec = Input.get_vector("J1_Aim_Left","J1_Aim_Right","J1_Aim_Up","J1_Aim_Down")
	if aim_vec.length() <= 0.2:
		aim_vec = Vector2.ZERO
	if Input.is_action_just_pressed("J1_Grapple"):
		shoot(Vector2.RIGHT.rotated(arrow.rotation))


func rotate_viewfinder():
	if aim_vec.length() > 0.2:
		arrow.rotation = lerp_angle(arrow.rotation, aim_vec.angle(), 0.2)


func rectify_position():
	if global_position.x < 0 - radius:
		global_position.x = screen_size.x + radius
	if global_position.x > screen_size.x + radius:
		global_position.x = 0 - radius
	if global_position.y < 0 - radius:
		global_position.y = screen_size.y + radius
	if global_position.y > screen_size.y + radius:
		global_position.y = 0 - radius


func shoot(direction: Vector2):
	can_shoot = false
	arrow.visible = false
	
	var target: Vector2 = grapple.points[0] + direction * shoot_dist
	if raycast.is_colliding():
		target = raycast.get_collision_point() - global_position
	
	var shoot_tween: Tween = create_tween()
	await shoot_tween.tween_method(
		func(v: Vector2) -> void:
			var pts = grapple.points
			pts[1] = v
			grapple.points = pts,
		grapple.points[1],
		target,
		0.1
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).finished
