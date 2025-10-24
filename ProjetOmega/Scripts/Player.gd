class_name Player extends Node2D

@export var id: String = "J1"
@export var player_color: Color = Color(0.204, 0.569, 0.0)
@export var mesh: MeshInstance2D
@export var collision_shape: CollisionShape2D
@export var controller: PlayerController
@export var arrow: Node2D
@export var grapple: Line2D
@export var raycast: RayCast2D
@export var fake_target_prefab: PackedScene
@export var fake_targets_parent: Node2D
@export var fake_targets: Array[FakeTarget]
@export var sound_manager: Clock

@export var starting_speed: float = 75.0
@export var shoot_dist: float = 50.0
@export var retract_speed: float = 40.0
@export var min_dist_on_grab: float = 5.0
@export var gainable_speed_per_grab: float = 50.0
@export var screen_vertical_offset: float = 32.0
@export var grab_detection_time: float = 0.1

var following_stars: Array[Star]
var screen_size: Vector2
var speed: Vector2
var last_pos: Vector2
var shoot_tween: Tween
var actual_speed: float
var radius: float
var rotation_angle: float = 0.0
var first_dist_to_planet: float
var dist_to_planet: float
var min_grab_speed: float
var max_grab_speed: float

var is_stopped: bool = true
var grabbed_planet: Planet = null
var aim_vec: Vector2 = Vector2.ZERO
var is_free: bool = true
var can_shoot: bool = true
var is_clockwise_rot: bool = true
var is_grab_detecting: bool = false


func _ready() -> void:
	controller.osc_address = controller.osc_address + "/" + id.to_lower()
	mesh.self_modulate = player_color
	actual_speed = starting_speed
	speed = Vector2.RIGHT.rotated(randf() * TAU) * actual_speed
	screen_size = get_viewport_rect().size
	screen_size.y -= screen_vertical_offset
	raycast.target_position = Vector2(shoot_dist, 0.0)
	if collision_shape.shape is CircleShape2D:
		radius = collision_shape.shape.radius


func _process(_delta: float) -> void:
	get_inputs()
	
	if is_grab_detecting:
		grapple_detect()


func _physics_process(delta: float) -> void:
	if is_free:
		if not is_stopped: free_move(delta)
		rotate_viewfinder()
	else:
		handle_grapping(delta)
		rotate_arround_grabbed_planet(delta)
	rectify_position()
	last_pos = global_position


func get_inputs() -> void:
	aim_vec = controller.get_vector()
	var get_manette: Vector2 = Input.get_vector(id + "_Aim_Left", id + "_Aim_Right", id + "_Aim_Up", id + "_Aim_Down")
	if get_manette.length() > 0.2:
		aim_vec = get_manette
	
	if aim_vec.length() <= 0.2:
		aim_vec = Vector2.ZERO
	if controller.is_action_just_pressed() or Input.is_action_just_pressed(id + "_Grapple"):
		if is_free:
			shoot(Vector2.RIGHT.rotated(arrow.rotation))
		else:
			break_free()


func free_move(delta: float) -> void:
	global_position += speed * delta


func change_dir(normalized_dir: Vector2) -> void:
	if is_free:
		speed = normalized_dir * actual_speed
	else:
		is_clockwise_rot = !is_clockwise_rot


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
	var old_pos: Vector2 = global_position
	if global_position.x < 0 - radius:
		global_position.x = screen_size.x + radius
		handle_reposition(old_pos)
	if global_position.x > screen_size.x + radius:
		global_position.x = 0 - radius
		handle_reposition(old_pos)
	if global_position.y < 0 - radius:
		global_position.y = screen_size.y + radius
		handle_reposition(old_pos)
	if global_position.y > screen_size.y + radius:
		global_position.y = 0 - radius
		handle_reposition(old_pos)


func shoot(aim_dir: Vector2) -> void:
	can_shoot = false
	arrow.visible = false
	var grapple_target: Vector2 = set_grapple_target(aim_dir)
	
	shoot_tween = create_tween()
	await shoot_tween.tween_method(
		func(v: Vector2) -> void:
			var pts = grapple.points
			pts[1] = v
			grapple.points = pts,
		grapple.points[1],
		grapple_target,
		0.1
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN).finished
	
	if is_free:
		reset_grapple()


func set_grapple_target(aim_dir: Vector2) -> Vector2:
	var target: Vector2 = grapple.points[0] + aim_dir * shoot_dist
	
	is_grab_detecting = true
	launch_stop_grab_detection_timer()
	
	if raycast.is_colliding():
		is_stopped = false
		grabbed_planet = raycast.get_collider().get_parent() as Planet
		var planet_to_player: Vector2 = global_position - grabbed_planet.global_position
		target = -planet_to_player
		set_grab_context(planet_to_player)
		is_free = false
	return target


func grapple_detect() -> void:
	if raycast.is_colliding():
		is_stopped = false
		grabbed_planet = raycast.get_collider().get_parent() as Planet
		var planet_to_player: Vector2 = global_position - grabbed_planet.global_position
		set_grab_context(planet_to_player)
		is_free = false
		is_grab_detecting = false


func launch_stop_grab_detection_timer() -> void:
	await get_tree().create_timer(grab_detection_time).timeout
	is_grab_detecting = false


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


func handle_reposition(old_pos: Vector2) -> void:
	break_free()
	if following_stars.size() > 0 :
		give_fake_target(old_pos, following_stars[0])


func break_free() -> void:
	if is_free:
		return
	var dist = (global_position - grabbed_planet.global_position).normalized()
	var orth = Vector2(dist.y, -dist.x) if is_clockwise_rot else Vector2(-dist.y, dist.x)
	speed = orth * actual_speed
	is_free = true
	reset_grapple()


func give_fake_target(old_pos: Vector2, star: Star) -> void:
	var free_target: FakeTarget = null
	for target: FakeTarget in fake_targets:
		if not target.is_used:
			free_target = target
			break
	if free_target == null:
		free_target = fake_target_prefab.instantiate()
		free_target.top_level = true
		fake_targets_parent.add_child(free_target)
		fake_targets.push_back(free_target)
	free_target.global_position = old_pos
	free_target.followed_by(star)
