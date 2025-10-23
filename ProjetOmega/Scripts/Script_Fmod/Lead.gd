extends FmodEventEmitter2D

var PlayNote : int
var increment = 0
var Down = false
var progression = 0
var PlayChordM
var PlayChordm
var IsLead = true
var Count
var Ignore = 1

func _ready():
	pass
	Count = Ignore - 1
	
func _process(_delta):
	pass
	
func _Play():
	pass


func _on_node_2d_bip(Notes, Scale, Chords, invertedbps) -> void:
	
	Count += 1
	
	if Count == Ignore:
		Count = 0
		if Notes[PlayNote] == "None":
			pass
		if IsLead == true:
			var Random = randi_range(0, 1)
			if Random == 1:
				pass
			else:
				print("true")
				PlayNote = Scale.pick_random()
				self.play()
				self.set_parameter("Note", Notes[PlayNote])
		else :
			PlayNote = Chords[increment]
			increment += 1
			if increment == 3:
				increment = 0
				self.play()
				self.set_parameter("Note", Notes[PlayNote])
				print("Note", Notes[PlayNote])
