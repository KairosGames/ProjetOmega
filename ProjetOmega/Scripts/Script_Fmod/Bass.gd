extends FmodEventEmitter2D

var clock: Clock
var player_emitter: PlayerEmitter
var PlayNote
var Count
var Ignore = 1
var increment : int = 0


func _ready():
	Count = Ignore - 1
	player_emitter = get_parent() as PlayerEmitter
	clock = get_parent().get_parent() as Clock


func _on_sound_manger_bip() -> void:
	var bass_player_intru: Array[int]
	if player_emitter.is_player1:
		bass_player_intru = clock.bass_intru_p1
	else:
		bass_player_intru = clock.bass_intru_p2
	if bass_player_intru.is_empty():
		pass
		print
	else:
		if bass_player_intru.has(clock.PlayBassNoteIndex):
			print("hasbidule")
			if clock.PlayBassNote == "none":
				pass
				print("none")
			else:
				print("pauv merde")
				self.set_parameter("SynthNote", clock.PlayBassNote)
				self.play()
				print(self.get_parameter("SynthNote"))
