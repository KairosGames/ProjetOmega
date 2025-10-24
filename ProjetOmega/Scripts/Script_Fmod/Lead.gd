extends FmodEventEmitter2D

var clock: Clock
var player_emitter: PlayerEmitter
var PlayNote : int
var increment = 0
var Down = false
var progression = 0
var PlayChordM
var PlayChordm
var IsLead = true
var Count
var Ignore = 1
var Stopped : bool = true


func _ready():
	Count = Ignore - 1
	player_emitter = get_parent() as PlayerEmitter
	clock = get_parent().get_parent() as Clock


func _on_sound_manger_bip() -> void:
	Count += 1
	
	if Count == Ignore:
		Count = 0
		if clock.Notes[PlayNote] == "None":
			pass
		if IsLead == true:
			var Random = randi_range(0, 1)
			if Random == 1:
				pass
			else:
				PlayNote = clock.Scale.pick_random()
				var lead_player_intru: Array[int]
				if player_emitter.is_player1:
					lead_player_intru = clock.lead_intru_p1
				else:
					lead_player_intru = clock.lead_intru_p2
				for n: int in lead_player_intru:
					if n == PlayNote:
						if Stopped == true:
							self.play()
						self.set_parameter("Note", clock.Notes[PlayNote])
		else :
			PlayNote = clock.Chords[increment]
			increment += 1
			if increment == 3:
				increment = 0
				self.play()
				self.set_parameter("Note", clock.Notes[PlayNote])


func _on_stopped() -> void:
	self.Stopped = true


func _on_started() -> void:
	self.Stopped = false
