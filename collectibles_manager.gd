extends Node2D
class_name Col_Manager

# ... autres variables ...

const FOLLOW_DISTANCE = 50.0  # 💡 Ajustez cette distance désirée (en unités de pixels)
const LERP_FACTOR = 0.1       # 💡 Facteur de lissage (entre 0.0 et 1.0, plus petit est plus lent)
@export var ChildArray : Array = []


func _physics_process(delta):
	FollowPlayerQueue(delta)
	
func FollowPlayerQueue(delta: float):
	# Itérer sur les index pour pouvoir accéder à l'élément précédent
	for i in range(ChildArray.size()):
		var current_coll = ChildArray[i]
		
		# 1. Déterminer le Nœud Cible de Référence
		var reference_node
		if i == 0:
			# Le premier collectible suit le Col_Manager (Player) lui-même
			reference_node = self 
		else:
			# Les autres suivent le collectible précédent (i - 1)
			reference_node = ChildArray[i - 1]
			
		# 2. Calculer la position souhaitée (la cible avec le décalage)
		
		# 🎯 CORRECTION MAJEURE : Utiliser global_position pour les positions dans le monde
		var current_global_pos = current_coll.global_position # Position actuelle du collectible dans le monde
		var target_global_pos = reference_node.global_position # Position de la cible dans le monde
		
		# Vecteur de direction de la position actuelle vers la cible
		var direction_vector = target_global_pos - current_global_pos
		
		# Si la cible est trop proche, ne bouge pas.
		if direction_vector.length_squared() < 1.0:
			continue

		# 3. Calculer la position qui maintient la distance de suivi
		var desired_global_pos = target_global_pos - direction_vector.normalized() * FOLLOW_DISTANCE
		
		# 4. Appliquer le Lissage (Lerp)
		# On fait le Lerp en coordonnées globales
		var new_global_pos = current_global_pos.lerp(desired_global_pos, LERP_FACTOR)
		
		# 5. ASSIGNER en position GLOBALE (ou l'équivalent)
		# 🎯 CORRECTION MAJEURE : Assigner la position globale
		current_coll.global_position = new_global_pos
