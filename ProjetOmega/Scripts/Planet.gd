class_name Planet extends Node2D

@export var particles: GPUParticles2D
@export var static_collision_shape: CollisionShape2D
@export var area_collision_shape: CollisionShape2D
@export var mesh: MeshInstance2D
@export var radius: float = 7.0


func _ready() -> void:
	var static_coll_shape: Shape2D = static_collision_shape.shape.duplicate()
	static_collision_shape.shape = static_coll_shape
	if static_collision_shape.shape is CircleShape2D:
		static_collision_shape.shape.radius = radius
	
	var area_coll_shape: Shape2D = area_collision_shape.shape.duplicate()
	area_collision_shape.shape = area_coll_shape
	if area_collision_shape.shape is CircleShape2D:
		area_collision_shape.shape.radius = radius
	
	var unique_mesh: SphereMesh = mesh.mesh.duplicate(true)
	mesh.mesh = unique_mesh
	if mesh.mesh is SphereMesh:
		mesh.mesh.radius = radius
		mesh.mesh.height = radius * 2
	
	var ratio: float = (radius/7.0)
	if ratio > 1.5:
		ratio *= 0.8
	particles.global_scale = Vector2(ratio, ratio)
	


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.get_parent() is Player:	
		var player = body.get_parent() as Player
		player.change_dir(player.speed.normalized().bounce((player.global_position - global_position).normalized()))
