extends Node

var bpm : float = 400
var invertedbps
var First 
var Second 
var Third 
var Fourth
var Do = 1
var Réb = 2
var Ré = 3
var Mib = 4
var Mi = 5
var Fa = 6
var Solb = 7
var Sol = 8
var Lab = 9
var La = 10
var Sib = 11
var Si = 12
var Notes = ["None", "Do", "Réb", "Ré", "Mib", "Mi", "Fa", "Solb", "Sol", "La", "Lab", "Sib", "Si", "Do2", "Réb2", "Ré2", "Mib2", "Mi2", "Fa2", "Solb2", "Sol2", "Lab2","La2", "Sib2", "Si2", "Do3", "Réb3", "Ré3", "Mib3", "Mi3", "Fa3", "Solb3", "Sol3", "Lab3","La3", "Sib3", "Si3"]
var I
var II
var III
var IV
var V
var VI
var VII
var I2
var Scale
var PlayNote
var Chords
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
	_Generate()
	_Clock()
	
func _Generate():
	Chords = [I, Scale.pick_random(), Scale.pick_random(), Scale.pick_random()]
	print(Scale)
	
func _Clock():
	invertedbps = 60 / bpm
	
	await get_tree().create_timer(invertedbps).timeout
	emit_signal("Bip", Notes ,Scale, Chords, invertedbps)
	increment += 1
	if increment == 16:
		increment = 0
		_Generate()
	_Clock()
	
func _NewChords():
	print("NewChords", Chords)
	Chords = [I, Scale[randf_range(0, 7)], Scale[randf_range(0, 7)], IV ]
