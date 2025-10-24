extends FmodEventEmitter2D

var clock: Clock
var player_emitter: PlayerEmitter
var PlayNote
var Count
var Ignore = 4
var P1 : Array[int]
var P2 : Array[int]
var NewParent = false

func _ready():
	pass
	Count = Ignore
	clock = get_parent() as Clock
	
func _on_sound_manger_bip() -> void:
	
	await get_tree().create_timer(clock.invertedbps * 2).timeout
	
	P1 = clock.drums_intru_p1
	P2 = clock.drums_intru_p2
	
	if P1.has(clock.Snare):
		self.reparent(clock.player1)
		NewParent = true
		self.global_position = get_parent().global_position
	if P2.has(clock.Snare):
		self.reparent(clock.player2)
		NewParent = true
		self.global_position = get_parent().global_position
		
	if Count == Ignore:
		if NewParent == true:
			self.play()
		Count = 0
	Count +=1
