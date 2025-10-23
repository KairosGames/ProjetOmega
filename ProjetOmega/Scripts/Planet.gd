class_name Planet extends Node2D

@export var collision_shape: CollisionShape2D

var radius: float


func _ready() -> void:
	if collision_shape.shape is CircleShape2D:
		radius = collision_shape.shape.radius


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.get_parent() is Player:
		var player = body.get_parent()
