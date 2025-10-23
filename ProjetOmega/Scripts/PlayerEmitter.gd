class_name PlayerEmitter extends Node2D

@export var is_player1: bool
var clock: Clock
var player_to_follow: Player

func _ready() -> void:
	clock = get_parent() as Clock
	if is_player1:
		player_to_follow = clock.player1
	else:
		player_to_follow = clock.player2

func _physics_process(_delta: float) -> void:
	global_position = player_to_follow.global_position
