extends FmodEventEmitter2D

var PlayNote
var Count
var Ignore = 4

func _ready():
	pass
	Count = Ignore - 1

func _on_node_2d_bip(Notes, Scale, Chords, invertedbps) -> void:
	await get_tree().create_timer(invertedbps).timeout
	Count +=1
	PlayNote = Scale.pick_random()
	
	if Count == Ignore:
		if Notes[PlayNote] == "None":
			pass
		else:
			self.play()
			
		await get_tree().create_timer(invertedbps).timeout
		Count = 0
