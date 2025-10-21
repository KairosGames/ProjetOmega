class_name Player extends Node2D

@export var collision_shape: CollisionShape2D
@export var arrow: Node2D
@export var grapple: Line2D
@export var raycast: RayCast2D

@export var starting_speed: float = 150.0
@export var shoot_dist: float = 100.0

var screen_size: Vector2
var speed: Vector2
var last_pos: Vector2
var actual_speed: float
var radius: float

var grabbed_planet: Planet = null
var aim_vec: Vector2 = Vector2.ZERO
var rotation_angle: float = 0.0
var dist_to_planet: float = 0.0
var is_free: bool = true
var can_shoot: bool = true
var is_clockwise_rot: bool = true


func _ready() -> void:
	actual_speed = starting_speed
	speed = Vector2.RIGHT.rotated(randf() * TAU) * actual_speed
	screen_size = get_viewport_rect().size
	if collision_shape.shape is CircleShape2D:
		radius = collision_shape.shape.radius


func _process(_delta: float) -> void:
	get_inputs()


func _physics_process(delta: float) -> void:
	if is_free:
		free_move(delta)
		rotate_viewfinder()
	else:
		rotate_arround_grabbed_planet(delta)
	rectify_position()
	last_pos = global_position


func get_inputs():
	aim_vec = Input.get_vector("J1_Aim_Left","J1_Aim_Right","J1_Aim_Up","J1_Aim_Down")
	if aim_vec.length() <= 0.2:
		aim_vec = Vector2.ZERO
	if Input.is_action_just_pressed("J1_Grapple"):
		if is_free:
			shoot(Vector2.RIGHT.rotated(arrow.rotation))
		else:
			break_free()


func free_move(delta: float) -> void:
	global_position += speed * delta


func rotate_viewfinder() -> void:
	if aim_vec.length() > 0.2:
		arrow.rotation = lerp_angle(arrow.rotation, aim_vec.angle(), 0.2)


func rotate_arround_grabbed_planet(delta: float) -> void:
	var dist: float = (grabbed_planet.global_position - global_position).length()
	var dir: float = -1.0 if is_clockwise_rot else 1.0
	var omega: float = (actual_speed / dist) * dir
	rotation_angle += omega * delta
	global_position = grabbed_planet.global_position + Vector2.RIGHT.rotated(rotation_angle) * dist
	grapple.points[1] = grabbed_planet.global_position - global_position


func rectify_position() -> void:
	if global_position.x < 0 - radius:
		global_position.x = screen_size.x + radius
	if global_position.x > screen_size.x + radius:
		global_position.x = 0 - radius
	if global_position.y < 0 - radius:
		global_position.y = screen_size.y + radius
	if global_position.y > screen_size.y + radius:
		global_position.y = 0 - radius


func shoot(aim_dir: Vector2) -> void:
	can_shoot = false
	arrow.visible = false
	var grapple_target: Vector2 = set_grapple_target(aim_dir)
	
	var shoot_tween: Tween = create_tween()
	await shoot_tween.tween_method(
		func(v: Vector2) -> void:
			var pts = grapple.points
			pts[1] = v
			grapple.points = pts,
		grapple.points[1],
		grapple_target,
		0.1
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).finished
	
	if is_free:
		reset_grapple()


func set_grapple_target(aim_dir: Vector2) -> Vector2:
	var target: Vector2 = grapple.points[0] + aim_dir * shoot_dist
	if raycast.is_colliding():
		grabbed_planet = raycast.get_collider().get_parent() as Planet
		var dist: Vector2 = global_position - grabbed_planet.global_position
		target = -dist
		rotation_angle = dist.angle()
		is_clockwise_rot = true if dist.cross(speed) < 0 else false
		is_free = false
	return target


func reset_grapple() -> void:
	grapple.points[1] = Vector2.ZERO
	can_shoot = true
	arrow.visible = true


func break_free() -> void:
	var dist = (global_position - grabbed_planet.global_position).normalized()
	var orth = Vector2(dist.y, -dist.x) if is_clockwise_rot else Vector2(-dist.y, dist.x)
	speed = orth * actual_speed
	is_free = true
	reset_grapple()
