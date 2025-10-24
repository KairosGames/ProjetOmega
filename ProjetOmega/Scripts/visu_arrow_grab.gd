extends Polygon2D

func _ready() -> void:
	var player: Player = get_parent().get_parent()
	color = player.player_color
