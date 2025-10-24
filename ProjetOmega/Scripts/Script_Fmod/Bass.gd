extends FmodEventEmitter2D

var clock: Clock
var player_emitter: PlayerEmitter
var PlayNote
var Count
var Ignore = 4
var increment : int = 0
var Stopped : bool = true

func _ready():
	Count = Ignore - 1
	player_emitter = get_parent() as PlayerEmitter
	clock = get_parent().get_parent() as Clock


func _on_sound_manger_bip() -> void:
	var bass_player_intru: Array[int]
	Count += 1
	if player_emitter.is_player1:
		bass_player_intru = clock.bass_intru_p1
	else:
		bass_player_intru = clock.bass_intru_p2
	if Count == Ignore:
		if not bass_player_intru.is_empty() and clock.PlayBassNote != "None":
			if Stopped == true:
				self.play()
				Stopped = false
			await get_tree().process_frame
			self.set_parameter("Note", clock.PlayBassNote)
		Count = 0


func _on_stopped() -> void:
	self.Stopped = true
