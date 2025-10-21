extends Area2D

var DefaultScale;
var C_Manager : Col_Manager
const SPACING = 5
func _ready():
	DefaultScale = scale

func DivideSizeBy(Size: int ):
	scale -= Vector2(Size, Size);
	
func SetPosAt( offset : int):
	for i in range(C_Manager.ChildArray.size()):
		var current_coll = C_Manager.ChildArray[i] # on get le collectible actuel
		var ref_pos : Vector2 # on cree un vector2
		if i ==0:
			ref_pos = C_Manager.position  # on assigne la pos du Manager
		else:
			var previous_coll = C_Manager.ChildArray[i-1] # on récupère l'index précedent
			ref_pos = previous_coll.position # on récup la pos de l'index précedent
				
		var current_offset = Vector2(offset + (i * SPACING), offset + (i * SPACING))
		current_coll.position = ref_pos + current_offset #on assigne la position au collectible
			

func _on_body_entered(body):
	if body.is_in_group("Player"):
		if body.get_child(Col_Manager):
			C_Manager = body.get_child(Col_Manager)
			C_Manager.ChildArray.append(self) # ajoute le collectible à la lsite.
			C_Manager.add_child(self)
		DivideSizeBy(2)
		SetPosAt(10) #test offset position.
		
	

# Après : faire une list où ajouter les enfants dans le parent. 
# Pour chacun, leur ajouter un offset pour qu'ils aient tous une position & qu'il suivent le joueur
# En gros l'offset : une fois l'objet dans la lsite, si c'est le 1er objet de la list / que la liste
#est vide, alors il "regarde" le player  & se place avec un certain offset. Si la liste est déja occupée
# alors l'item actuelle regarde le précédent & se place avec un offset.
