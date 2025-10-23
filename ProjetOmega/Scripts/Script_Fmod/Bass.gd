extends FmodEventEmitter2D

var PlayNote
var Count
var Ignore = 2
var increment : int = 0
var Owner

func _ready():
	pass
	Count = Ignore - 1
	
func _on_node_2d_bip(Notes, Scale, Chords, invertedbps) -> void:
	
	Count += 1
	
	PlayNote = Chords[increment]
	if increment == 3:
		increment = 0
	
	if Count == Ignore:
		increment +=1
		Count =0
		if Notes[PlayNote] == "None":
			pass
		else:
			self.play()
			self.set_parameter("Synth_Note", Notes[PlayNote])
			print("Synth_Note", Notes[PlayNote])
