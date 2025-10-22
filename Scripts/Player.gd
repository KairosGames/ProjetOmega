class_name Player extends Node2D

@export var id: String = "J1"
@export var player_color: Color = Color(0.204, 0.569, 0.0)
@export var mesh: MeshInstance2D
@export var collision_shape: CollisionShape2D
@export var arrow: Node2D
@export var grapple: Line2D
@export var raycast: RayCast2D

@export var starting_speed: float = 75.0
@export var shoot_dist: float = 50.0
@export var retract_speed: float = 40.0
@export var min_dist_on_grab: float = 5.0
@export var gainable_speed_per_grab: float = 50.0

var following_stars: Array[Star]
var screen_size: Vector2
var speed: Vector2
var last_pos: Vector2
var actual_speed: float
var radius: float
var rotation_angle: float = 0.0
var first_dist_to_planet: float
var dist_to_planet: float
var min_grab_speed: float
var max_grab_speed: float

var grabbed_planet: Planet = null
var aim_vec: Vector2 = Vector2.ZERO
var is_free: bool = true
var can_shoot: bool = true
var is_clockwise_rot: bool = true


func _ready() -> void:
	mesh.self_modulate = player_color
	actual_speed = starting_speed
	speed = Vector2.RIGHT.rotated(randf() * TAU) * actual_speed
	screen_size = get_viewport_rect().size
	raycast.target_position = Vector2(shoot_dist, 0.0)
	if collision_shape.shape is CircleShape2D:
		radius = collision_shape.shape.radius


func _process(_delta: float) -> void:
	get_inputs()


func _physics_process(delta: float) -> void:
	if is_free:
		free_move(delta)
		rotate_viewfinder()
	else:
		handle_grapping(delta)
		rotate_arround_grabbed_planet(delta)
	rectify_position()
	last_pos = global_position


func get_inputs() -> void:
	aim_vec = Input.get_vector(id+"_Aim_Left",id+"_Aim_Right",id+"_Aim_Up",id+"_Aim_Down")
	if aim_vec.length() <= 0.2:
		aim_vec = Vector2.ZERO
	if Input.is_action_just_pressed(id+"_Grapple"):
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
	var dir: float = -1.0 if is_clockwise_rot else 1.0
	var omega: float = (actual_speed / dist_to_planet) * dir
	rotation_angle += omega * delta
	global_position = grabbed_planet.global_position + Vector2.RIGHT.rotated(rotation_angle) * dist_to_planet
	grapple.points[1] = grabbed_planet.global_position - global_position


func handle_grapping(delta: float) -> void:
	if aim_vec.length() > 0.2:
		var strength = aim_vec.dot((grabbed_planet.global_position - global_position).normalized())
		dist_to_planet -= strength * delta * retract_speed
		if dist_to_planet <= grabbed_planet.radius + radius + min_dist_on_grab:
			dist_to_planet = grabbed_planet.radius + radius + min_dist_on_grab
		if dist_to_planet >= shoot_dist:
			dist_to_planet = shoot_dist
	var ratio: float = (dist_to_planet - grabbed_planet.radius - radius - min_dist_on_grab) / (shoot_dist - grabbed_planet.radius - radius - min_dist_on_grab)
	if ratio < 0 : ratio = 0.0
	actual_speed = min_grab_speed + ((max_grab_speed - min_grab_speed) * (1.0 - ratio))


func rectify_position() -> void:
	if global_position.x < 0 - radius:
		global_position.x = screen_size.x + radius
		break_free()
	if global_position.x > screen_size.x + radius:
		global_position.x = 0 - radius
		break_free()
	if global_position.y < 0 - radius:
		global_position.y = screen_size.y + radius
		break_free()
	if global_position.y > screen_size.y + radius:
		global_position.y = 0 - radius
		break_free()


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
		var planet_to_player: Vector2 = global_position - grabbed_planet.global_position
		target = -planet_to_player
		set_grab_context(planet_to_player)
		is_free = false
	return target


func set_grab_context(planet_to_player: Vector2) -> void:
	rotation_angle = planet_to_player.angle()
	is_clockwise_rot = true if planet_to_player.cross(speed) < 0 else false
	first_dist_to_planet = planet_to_player.length()
	dist_to_planet = first_dist_to_planet
	var ratio = (dist_to_planet - grabbed_planet.radius - radius - min_dist_on_grab) / (shoot_dist - grabbed_planet.radius - radius - min_dist_on_grab)
	if ratio < 0 : ratio = 0.0
	min_grab_speed = actual_speed - ((1.0 - ratio) * gainable_speed_per_grab)
	max_grab_speed = actual_speed + (ratio * gainable_speed_per_grab)


func reset_grapple() -> void:
	grapple.points[1] = Vector2.ZERO
	can_shoot = true
	arrow.visible = true


func break_free() -> void:
	if is_free:
		return
	var dist = (global_position - grabbed_planet.global_position).normalized()
	var orth = Vector2(dist.y, -dist.x) if is_clockwise_rot else Vector2(-dist.y, dist.x)
	speed = orth * actual_speed
	is_free = true
	reset_grapple()
