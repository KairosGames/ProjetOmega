class_name Clock extends Node

@export var player1: Player
@export var player2: Player

var lead_intru_p1: Array[int]
var bass_intru_p1: Array[int]
var drums_intru_p1: Array[int]
var lead_intru_p2: Array[int]
var bass_intru_p2: Array[int]
var drums_intru_p2: Array[int]

var lead_list: Array[int]
var bass_list: Array[int]
var drums_list: Array[int]


var bpm : float = 400
var invertedbps: float
var Notes = ["None", "Do", "Réb", "Ré", "Mib", "Mi", "Fa", "Solb", "Sol", "La", "Lab", "Sib", "Si", "Do2", "Réb2", "Ré2", "Mib2", "Mi2", "Fa2", "Solb2", "Sol2", "Lab2","La2", "Sib2", "Si2", "Do3", "Réb3", "Ré3", "Mib3", "Mi3", "Fa3", "Solb3", "Sol3", "Lab3","La3", "Sib3", "Si3"]
var I: int
var II: int
var III: int
var IV: int
var V: int
var VI: int
var VII: int
var I2: int
var Scale: Array[int]
var Chords: Array[int]
var increment = 0

signal Bip(Notes, Scale)

func _ready():
	I = randi_range(1, 12)
	II = I + 2
	III = I + 4
	IV = I + 5
	V = I + 7
	VI = I + 9
	VII = I + 11
	I2 = I + 12
	Scale = [I, II, III, IV, V, VI, VII, I2]
	
	lead_list = [I, I2, V, IV, VI, II, III, VII]
	bass_list = [I, I2, V, IV, VI, II, III, VII]
	
	_Generate()
	_Clock()


func give_note(player_id: String, star_type: Star.StarType) -> void:
	var player_intru: Array[int]
	var source: Array[int]
	match star_type:
		Star.StarType.Blue:
			source = bass_list
			if player_id == "J1":
				player_intru = bass_intru_p1
			else:
				player_intru = bass_intru_p2
		Star.StarType.Red:
			source = lead_list
			if player_id == "J1":
				player_intru = lead_intru_p1
			else:
				player_intru = lead_intru_p2
		Star.StarType.Yellow:
			source = drums_list
			if player_id == "J1":
				player_intru = drums_intru_p1
			else:
				player_intru = drums_intru_p2
	if source.size() != 0:
		player_intru.push_back(source.pop_front())


func _Generate():
	Chords = [I, Scale.pick_random(), Scale.pick_random(), Scale.pick_random()]
	
func _Clock():
	invertedbps = 60 / bpm
	await get_tree().create_timer(invertedbps).timeout
	emit_signal("Bip")
	increment += 1
	if increment == 16:
		increment = 0
		_Generate()
	_Clock()
	
func _NewChords():
	Chords = [I, Scale[randf_range(0, 7)], Scale[randf_range(0, 7)], IV ]
