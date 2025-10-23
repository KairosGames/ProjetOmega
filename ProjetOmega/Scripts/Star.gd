class_name Star extends Node2D

enum StarType {Blue, Red, Yellow}

@export var area: Area2D
@export var mesh: MeshInstance2D
@export var cover: MeshInstance2D
@export var collider: CollisionShape2D

@export var type: StarType = StarType.Blue
@export var min_dist_to_target: float = 5.0
@export var rotation_speed: float = 5.0

var speed: float
var index: int = -1
var is_free: bool = true
var is_full: bool = false
var has_to_join: bool = false
var has_to_be_joined: bool = false
var is_completed: bool = false

var targets: Array[Node2D]
var player: Player
var radius: float


func _ready() -> void:
	if mesh.mesh is SphereMesh:
		radius = mesh.mesh.radius
	match type:
		StarType.Blue:
			mesh.self_modulate = Color(0.428, 0.688, 1.0, 1.0)
		StarType.Red:
			mesh.self_modulate = Color(1.0, 0.379, 0.389, 1.0)
		StarType.Yellow:
			mesh.self_modulate = Color(0.957, 0.802, 0.0, 1.0)
	rotation = randf() * TAU


func _physics_process(delta: float) -> void:
	if not is_full and not has_to_join and not has_to_be_joined:
		auto_rotate(delta)
	if not is_free and not has_to_join:
		follow_target(delta)
	if has_to_join:
		join_to_complete(delta)
	if has_to_be_joined:
		rotate_to_be_completed(delta)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not is_free:
		return
	if body.get_parent() is Player:
		player = body.get_parent()
		handle_context()


func auto_rotate(delta: float) -> void:
	global_rotation += rotation_speed * delta


func follow_target(_delta: float) -> void:
	if targets.size() <= 0:
		return
	var dist: Vector2 = targets[0].global_position - global_position
	if targets.size() > 1:
		global_position = lerp(global_position, targets[0].global_position, 0.3)
		rectify_position()
		return
	if dist.length() > min_dist_to_target + targets[0].radius + radius:
		global_position = lerp(global_position, targets[0].global_position, 0.1)
	else:
		global_position = targets[0].global_position - (dist.normalized() * (min_dist_to_target + targets[0].radius + radius))


func join_to_complete(_delta: float) -> void:
	global_rotation = lerp(global_rotation, deg_to_rad(180.0), 0.1)
	global_position = lerp(global_position, targets[0].global_position, 0.1)
	var target = targets[0] as Star
	if (target.global_position - global_position).length() < 1:
		target.has_to_be_joined = false
		target.cover.visible = false
		target.is_completed = true
		queue_free()


func rotate_to_be_completed(_delta: float) -> void:
	global_rotation = lerp(global_rotation, deg_to_rad(0.0), 0.1)


func handle_context() -> void:
	if player.following_stars.size() != 0:
		for star: Star in player.following_stars:
			if star.type == type:
				if star.is_full: return
				star.is_full = true
				star.has_to_be_joined = true
				has_to_join = true
				set_new_links(star, false)
				call_deferred("get_new_parent")
				return
		set_new_links(player.following_stars[-1])
	else:
		set_new_links(player)


func set_new_links(target: Node2D, add_to_player = true) -> void:
	if (add_to_player):
		player.following_stars.push_back(self)
		if target is Player:
			index = 0
		else:
			index = target.index + 1
	targets.push_front(target)
	is_free = false
	call_deferred("disable_collider")


func disable_collider() -> void:
	collider.disabled = true


func get_new_parent() -> void:
	reparent(targets[0])


func rectify_position() -> void:
	var old_pos: Vector2 = global_position
	if global_position.x < 0 - radius:
		global_position.x = player.screen_size.x + radius
		handle_reposition(old_pos)
	if global_position.x > player.screen_size.x + radius:
		global_position.x = 0 - radius
		handle_reposition(old_pos)
	if global_position.y < 0 - radius:
		global_position.y = player.screen_size.y + radius
		handle_reposition(old_pos)
	if global_position.y > player.screen_size.y + radius:
		global_position.y = 0 - radius
		handle_reposition(old_pos)


func handle_reposition(old_pos: Vector2) -> void:
	if player.following_stars.size() > index + 1:
			player.give_fake_target(old_pos, player.following_stars[index +1])
	targets.pop_front()
