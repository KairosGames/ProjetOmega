extends Area2D

class_name Collectible
var DefaultScale
var C_Manager : Col_Manager 
const SPACING = 5
var Target : Node2D
var IsMoving : bool = false

func _ready():
	DefaultScale = scale

func DivideSizeBy(Size: int ):
	if scale == DefaultScale:
		scale = scale / Size
	

func _on_body_entered(body):
	if body.is_in_group("Player") && IsMoving == false:
		var found_manager : Col_Manager = null
		for child in body.get_children():
			if child is Col_Manager:
				found_manager = child
				break
		if is_instance_valid(found_manager):
			C_Manager = found_manager
			
			C_Manager.ChildArray.append(self) # ajoute le collectible à la lsite.
			C_Manager.add_child(self)
			IsMoving = true
			
			DivideSizeBy(5)
			
	


# Après : faire une list où ajouter les enfants dans le parent. 
# Pour chacun, leur ajouter un offset pour qu'ils aient tous une position & qu'il suivent le joueur
# En gros l'offset : une fois l'objet dans la lsite, si c'est le 1er objet de la list / que la liste
#est vide, alors il "regarde" le player  & se place avec un certain offset. Si la liste est déja occupée
# alors l'item actuelle regarde le précédent & se place avec un offset.
