extends FmodEventEmitter2D

var PlayNote
var Count
var Ignore = 2

func _ready():
	pass
	Count = Ignore - 1

func _on_node_2d_bip(Notes, Scale, Chords, invertedbps) -> void:
		Count +=1
		
		if Count == Ignore:
			var Random = randi_range(0, 1)
			if Random == 0:
				self.play()
				await get_tree().create_timer(invertedbps / 2 ).timeout
				
				
		Count = 0
