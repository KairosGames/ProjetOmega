extends FmodEventEmitter2D

var clock: Clock
var player_emitter: PlayerEmitter
var PlayNote
var Count
var Ignore = 2
var increment : int = 0
var Owner


func _ready():
	Count = Ignore - 1
	player_emitter = get_parent() as PlayerEmitter
	clock = get_parent().get_parent() as Clock


func _on_sound_manger_bip() -> void:
	Count += 1
	PlayNote = clock.Chords[increment]
	var bass_player_intru: Array[int]
	if player_emitter.is_player1:
		bass_player_intru = clock.bass_intru_p1
	else:
		bass_player_intru = clock.bass_intru_p2
	for n: int in bass_player_intru:
		if n == PlayNote:
			if increment == 3:
				increment = 0
			if Count == Ignore:
				increment +=1
				Count =0
				if  clock.Notes[PlayNote] == "None":
					pass
				else:
					self.play()
					self.set_parameter("Synth_Note", clock.Notes[PlayNote])
